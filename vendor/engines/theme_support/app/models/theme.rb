require 'theme/files'

class Theme
  class ThemeError < StandardError; end
  
  @@default_preview_path = RAILS_ROOT + '/public/plugin_assets/theme_support/images/preview.png'
  
  cattr_accessor :root_dir
  @@root_dir = RAILS_ROOT
  
  attr_accessor :path, :id, :errors
    
  class << self
    def find(ids, subdir = nil)
      case ids
        when :all   then themes(subdir)
        when Array  then themes(subdir).select{|theme| ids.include? theme.id }
        else             themes(subdir).detect{|theme| ids == theme.id }
      end
    end    
    
    def create!(attrs)
      returning Theme.new(attrs) do |theme|
        theme.save
      end
    end
    
    def to_id(str)
      str.gsub(/[^\w\-_]/, '_').downcase
    end
    
    def base_dir
      ::File.join(root_dir, "themes")
    end
    
    protected
    
    def themes(subdir = nil)
      installed_theme_paths(subdir).inject([]) do |array, path|
        array << new(:path => path)
      end
    end

    def installed_theme_paths(subdir = nil)    
      pattern = ::File.join *[base_dir, subdir, '[-_a-zA-Z0-9]*'].compact
      Dir.glob(pattern).collect { |file| file if ::File.directory?(file) }.compact
    end  
  end

  def initialize(attrs = {})
    @errors = []
    attrs['id'] = self.class.to_id(attrs['name']) if attrs['name'] && !attrs['id']
    attrs['path'] += attrs['id'] if attrs['id']
    self.attributes = attrs
  end
  
  # TODO introduce fullpath and/or basepath?
  
  def local_path
    @path.sub(self.class.base_dir, '').sub(/\//, '')
  end
  
  def path=(path)
    raise ThemeError.new('invalid file path #{path}. a path may not contain any of: \'"<>') if @path.to_s =~ /['"<>]/
    path = path.to_s
    path.untaint
    mv Pathname.new(path)
    @id = path.to_s.scan(/[-\w]+$/i).flatten.first
    @id.untaint
  end

  [:version, :homepage, :author, :summary].each do |attr_name|
    eval <<-END
      def #{attr_name}
        about['#{attr_name}']
      end

      def #{attr_name}=(value)
        about['#{attr_name}'] = sanitize! value, :escape
      end
    END
  end
  
  def id=(id)
    if self.id and self.id != id
      self.path = Pathname.new(self.path.to_s.gsub(%r(/#{self.id}$), "/#{id}"))
    end
    @id = id
  end
  
  def name
    about['name']
  end
  
  def name=(name)
    about['name'] = name
    self.id = self.class.to_id(name)
  end
  
  def author_link
    name = author.blank? ? 'unknown' : author
    homepage.blank? ? name : %(<a href="#{homepage}">#{name}</a>)
  end
  
  def files
    @files ||= Class.new(Array) do
      def find(id)
        each do |files|
          file = files.find(id)
          return file if file
        end
        nil
      end
    end[templates, assets, others]
  end

  def templates
    @templates ||= Files.new(Theme::Template, self)
  end
  
  def assets
    @assets ||= Files.new(Theme::Asset, self)
  end
  
  def others
    @others ||= Files.new(Theme::Other, self)
  end

  def preview
    others.find('preview-png') || Theme::Other.default_preview(self, @@default_preview_path)
  end
  
  def update_attributes(attributes)
    update_attributes! attributes
  rescue ThemeError => e
    self.errors << e.message
  end
  
  def update_attributes!(attributes)
    self.attributes = attributes
    save!
  end
  
  def attributes=(attributes)
    valid_keys = [:id, :path, :name, :author, :version, :homepage, :summary]
    attributes.symbolize_keys.slice(*valid_keys).each do |name, value|
      send :"#{name}=", value if value
    end 
  end
  
  def save
    save!
  rescue ThemeError => e
    self.errors << e.message
  end
  
  def save!
    return false unless valid?
    mkdir
    write_about_file
    true
  end
    
  def valid?
    validate unless @validated
    errors.empty?
  end
  
  def validate
    errors << "Name can't be empty" if self.name.blank? 
    @validated = true
  end  
  
  def mkdir
    raise ThemeError.new("can't create directory #{@path}") unless @path.to_s =~ %r(^#{Theme.base_dir})
    FileUtils.mkdir_p @path.to_s 
  end
  
  def mv(path)
    raise ThemeError.new("can't rename to directory #{path}") unless path.to_s =~ %r(^#{Theme.base_dir})
    if @path and path != @path
      raise ThemeError.new("can't rename to existing directory #{path}") if ::File.exists?(path)
      FileUtils.mv @path.to_s, path.to_s 
    end
    @path = path
  end
  
  def destroy
    raise ThemeError.new("can't remove directory #{@path}") unless @path.to_s =~ %r(^#{Theme.base_dir})
    FileUtils.remove_dir @path.to_s 
  end

protected
  def about
    @about ||= if @path      
      about_filename.exist? ? read_about_file : {}
    end || {}
  end
  
  def about_filename
    @path + 'about.yml'
  end
  
  def read_about_file
    YAML.load_file(about_filename).each do |key, value| 
      sanitize! value, :escape
    end
  end
  
  def write_about_file
    ::File.open(about_filename, 'wb'){|f| f.write about.to_yaml }
  end

  class Sanitizer
    include ActionView::Helpers::SanitizeHelper 
  
    def sanitize(value)
      RailsSanitize.white_list_sanitizer.sanitize(value)
    end
  
    def strip_tags(value)
      RailsSanitize.full_sanitizer.sanitize(value)
    end
  
    def escape(value)
      CGI::escapeHTML(value)
    end      
  end

  def sanitize!(value, type = :sanitize)
    @sanitizer ||= Sanitizer.new
    value.replace @sanitizer.send(type, value)
    value.untaint
  end
end