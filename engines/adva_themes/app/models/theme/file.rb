Paperclip::Attachment.interpolations.merge! \
  :theme_file_url  => proc { |data, style| data.instance.url  },
  :theme_file_path => proc { |data, style| data.instance.path }

class Theme < ActiveRecord::Base
  class File < ActiveRecord::Base
    class_inheritable_writer :valid_extensions

    belongs_to :theme
    instantiates_with_sti

    has_attached_file :data,
                      :url => ":theme_file_url",
                      :path => ":theme_file_path",
                      :validations => { :extension => lambda { |data, file| validate_extension(data, file) } }

    before_save :force_directory

    validates_presence_of :name
    validates_uniqueness_of :name, :scope => :theme_id
    validates_attachment_presence :data
    validates_attachment_size :data, :less_than => 100.kilobytes

    validates_each :directory, :name do |record, attr, value|
      record.errors.add attr, 'may not contain consequtive dots' if value =~ /\.\./
    end

    # before_validation: whitelist allowed characters?

    class << self
      def new(attributes = {})
        path = attributes.delete(:path)
        type, directory, name, data = attributes.values_at(:type, :directory, :name, :data)

        directory, name = split_path(path) if path
        type ||= type_for(directory, name) if name
        data = StringIO.new(data) if data.is_a?(String)

        super attributes.merge(:type => type, :directory => directory, :name => name, :data => data)
      end
    
      def acceptable?(directory, name)
        valid_extensions.include?(::File.extname(name))
      end

      def type_for(directory, name)
        classes = subclasses.unshift(Preview).uniq # move Preview to the front
        classes.detect{ |k| k.acceptable?(directory, name) }.try(:name)
      end
      
      def type_by_extension(extension)
        subclasses.detect{ |k| k.valid_extensions.include?(extension) }
      end

      def validate_extension(data, file)
        if file.name && !file.class.valid_extensions.include?(::File.extname(file.name))
          types = all_valid_extensions.map{ |type| type.gsub(/^\./, '') }.join(', ')
          "#{file.name} is not a valid file type. Valid file types are #{types}."
        end
      end

      def valid_extensions
        read_inheritable_attribute(:valid_extensions) || []
      end

      def all_valid_extensions
        subclasses.map { |k| k.valid_extensions }.flatten.uniq
      end

      def join_path(*segments)
        segments.map{|segment| segment unless segment.blank? }.compact.join('/')
      end

      def split_path(path)
        directory, name = ::File.split(path)
        directory = nil if directory == '.'
        [directory, name]
      end
    end

    def path
      self.class.join_path(theme.path, directory, name) if name
    end

    def url
      self.class.join_path(theme.url, directory, name) if name
    end

    def base_url
      self.class.join_path(directory.gsub(/^#{forced_directory}\/?/, ''), name) if name
    end

    protected

      def prepend_directory(prefix)
        return directory if directory =~ /^#{prefix}/
        self.directory = self.class.join_path prefix, directory
      end

      def force_directory
        prepend_directory forced_directory
      end

      def forced_directory
        self.class.name.demodulize.downcase.pluralize
      end
  end
  
  class TextFile < File
    def data=(data)
      data = StringIO.new(data) if data.is_a?(String)
      super
    end

    def text
      @text ||= ::File.read(path) rescue ''
    end
  end

  class Image < File
    self.valid_extensions = %w(.jpg .jpeg .gif .png)
  end

  class Javascript < TextFile
    self.valid_extensions = %w(.js)
  end

  class Stylesheet < TextFile
    self.valid_extensions = %w(.css)
  end

  class Template < TextFile
    self.valid_extensions = %w(.erb .haml .liquid)
  end

  class Preview < File
    self.valid_extensions = %w(.jpg .jpeg .gif .png)

    class << self
      def new(attributes = {})
        if theme = attributes[:theme] and theme.preview then theme.preview.destroy end
        super attributes.except(:path).merge(:name => 'preview.png', :directory => 'images')
      end
    
      def acceptable?(directory, name)
        directory.to_s.gsub(/(images|\/|\.)*/, '').blank? and name == 'preview.png' 
      end
    end
    
    protected
    
      def force_directory
        self.directory = 'images'
      end

      def forced_directory
        'images'
      end
  end
end