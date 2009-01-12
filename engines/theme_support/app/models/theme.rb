require 'theme/files'

class Theme
  class ThemeError < StandardError; end

  @@default_preview_path = RAILS_ROOT + '/public/images/adva_cms/preview.png'

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

    def import(file)
      import_from_zip(file)
    end

    def to_id(str)
      str.gsub(/[^\w\-_]/, '_').downcase
    end

    def base_dir
      ::File.join(root_dir, "themes")
    end

    def make_tmp_dir
      random = Time.now.to_i.to_s.split('').sort_by{rand}
      returning Pathname.new(RAILS_ROOT + "/tmp/themes/tmp_#{random}/") do |dir|
        FileUtils.mkdir_p dir unless dir.exist?
      end
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

    def import_from_zip(file)
      name = file.original_filename.gsub(/(^.*(\\|\/))|(\.zip$)/, '').gsub(/[^\w\.\-]/, '_')
      tmp_dir = Theme.make_tmp_dir
      Zip::ZipFile.open(file.path) do |zip|
        zip.each do |entry|
          path = tmp_dir + name + entry.name
          FileUtils.mkdir_p ::File.dirname(path)
          entry.extract path
        end
      end
      Theme.new :path => tmp_dir + name
    end
  end

  def initialize(attrs = {})
    @errors = []
    attrs.symbolize_keys!
    attrs[:id] = self.class.to_id(attrs[:name]) if attrs[:name] && !attrs[:id]
    attrs[:path] += attrs[:id] if attrs[:id]
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
    id.gsub! %r([^\w-]), ''
    if self.id and self.id != id
      self.path = Pathname.new(self.path.to_s.gsub(%r(/#{self.id}$), "/#{id}"))
    end
    @id = id
  end

  def name
    about['name']
  end

  def name=(name)
    name.gsub! %r(/|\\), ''
    about['name'] = name
    self.id = self.class.to_id(name)
  end

  def author_link
    name = author.blank? ? I18n.t( :'adva.common.unknown' ) : author
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

  def about_file
    Theme::Other.new self, self.about_filename
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
    unless ::File.exists?(preview_path)
      FileUtils.mkdir_p ::File.dirname(preview_path)
      FileUtils.cp @@default_preview_path, preview_path 
    end
    assets.find('images-preview-png')
  end
  
  def preview_path
    "#{self.path}/images/preview.png"
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
    errors << I18n.t( :'adva.theme.validation.empty_name' ) if self.name.blank?
    @validated = true
  end

  def export(options = {})
    options.reverse_merge! :as => :zip
    send :"export_as_#{options[:as]}", Theme.make_tmp_dir
  end

  def mkdir
    raise ThemeError.new("can't create directory #{@path}") unless @path.to_s =~ %r(^#{Theme.base_dir})
    FileUtils.mkdir_p @path.to_s
  end

  def mv(path)
    # TODO this is crap. do not move the theme on create by default even if there's no
    # theme path set, yet. Also, took the following check out so we're able to create a theme
    # on a tmp directory and move it afterwards
    # raise ThemeError.new("can't rename to directory #{path}") unless path.to_s =~ %r(^#{Theme.base_dir})
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
  
  def ==(other)
    other and self.path == other.path
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

  def export_as_zip(dir)
    returning dir + "#{id}.zip" do |filename|
      filename.unlink if filename.exist?
      Zip::ZipFile.open filename, Zip::ZipFile::CREATE do |zip|
        zip.add('about.yml', about_filename)
        files.flatten.each{|file| zip.add(file.localpath.to_s, file.fullpath.to_s) }
      end
    end
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