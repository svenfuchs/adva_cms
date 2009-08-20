Paperclip::Attachment.interpolations.merge! \
  :theme_file_url  => proc { |data, style| data.instance.url  },
  :theme_file_path => proc { |data, style| data.instance.path }

class Theme < ActiveRecord::Base
  class File < ActiveRecord::Base
    class_inheritable_writer :valid_extensions
    class_inheritable_accessor :file_type

    belongs_to :theme
    instantiates_with_sti

    has_attached_file :data,
                      :url => ":theme_file_url",
                      :path => ":theme_file_path",
                      # FIXME fails with a weird file upload error
                      # Tempfile has a name like RackMultipart20090310-22070-hu8w3m-0 which is missing the extension
                      :validations => { :extension => lambda { |data, file| validate_extension(data, file) } }

    # NOTE before_save order is important here
    before_save :force_directory
    before_save :ensure_unique_filename
    after_save :move_data_file, :expire_asset_cache!

    validates_presence_of :name
    validates_uniqueness_of :name, :scope => [:theme_id, :directory]
    validates_attachment_presence :data
    validates_attachment_size :data, :less_than => 500.kilobytes

    validates_each :directory, :name do |record, attr, value|
      record.errors.add attr, 'may not contain consequtive dots' if value =~ /\.\./
    end

    validates_format_of :name, :with => /^\w/
    validates_format_of :directory, :with => /^\w/, :allow_nil => true, :allow_blank => true

    # before_validation: whitelist allowed characters?

    class << self
      def new(attributes = {})
        attributes ||= {}
        
        base_path = attributes.delete(:base_path)
        type, directory, name, data = attributes.values_at(:type, :directory, :name, :data)
        base_path ||= data.original_filename if data.respond_to?(:original_filename)

        directory, name = split_path(base_path) if base_path and name.blank?
        directory ||= ''
        type      ||= type_for(directory, name) if name
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

      def split_path(path)
        directory, name = ::File.split(path)
        directory = nil if directory == '.'
        [directory, name]
      end
    end

    def path
      [theme.path, directory, name].to_path if name
    end

    def base_path
      [directory, name].to_path if name
    end

    def base_path=(base_path)
      self.directory, self.name = self.class.split_path(base_path)
    end

    def url
      [theme.url, directory, name].to_path if name
    end

    def base_url
      [directory.gsub(/^#{forced_directory}\/?/, ''), name].to_path if name
    end
    
    def basename
      data_file_name.gsub(/\.#{extname}$/, "")
    end

    def extname
      ::File.extname(data_file_name).gsub(/^\.+/, '')
    end

    protected
    
      def expire_asset_cache!
        # for stylesheets and javascripts
      end

      def prepend_directory(prefix)
        return directory if directory =~ /^#{prefix}/
        self.directory = [prefix, directory].to_path
      end

      def force_directory
        prepend_directory forced_directory
      end

      def forced_directory
        self.class.name.demodulize.downcase.pluralize
      end

      def move_data_file
        if moved?
          mkdir_p(::File.dirname(path))
          FileUtils.mv(path_was, path)
          rm_empty_directories(path_was)
        end
      end

      def moved?
        not just_created? and (name_changed? or directory_changed?)
      end

      def path_was
        [theme.path, directory_was, name_was].to_path
      end

      def mkdir_p(dir)
        FileUtils.mkdir_p(dir) unless File.exists?(dir)
      end

      def rm_empty_directories(path)
        while path = ::File.dirname(path)
          FileUtils.rmdir(path)
        end
      rescue Errno::ENOTEMPTY, Errno::ENOENT, Errno::EINVAL
        # stop deleting directories
      end
      
      def ensure_unique_filename
        if new_record? || changes['data_file_name']
          basename, extname = self.basename, self.extname
          i = extname =~ /^\d+\./ ? $1 : 1
          while ::File.exists?(path)
            self.name = [basename, i, extname].to_path('.')
            self.data_file_name = [basename, i, extname].to_path('.')
            i += 1
          end
        end
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
    self.file_type = :image
    self.valid_extensions = %w(.jpg .jpeg .gif .png .ico)
  end

  class Javascript < TextFile
    self.file_type = :javascript
    self.valid_extensions = %w(.js)
    
    protected
      def expire_asset_cache!
        theme.clear_asset_cache!
      end
  end

  class Stylesheet < TextFile
    self.file_type = :stylesheet
    self.valid_extensions = %w(.css)
    
    protected
      def expire_asset_cache!
        theme.clear_asset_cache!
      end
  end

  class Template < TextFile
    self.file_type = :template
    self.valid_extensions = %w(.erb .haml .liquid)
  end

  class Preview < File
    self.file_type = :preview
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