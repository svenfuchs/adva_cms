class Theme
  class Path
    @@template_types = { '.rhtml'     => 'ERB',
                         '.html.erb'  => 'ERB',
                         '.html.haml' => 'Haml',
                         '.liquid'    => 'Liquid' }

    @@asset_types    = { '.js'   => 'text/javascript',
                         '.css'  => 'text/css',
                         '.png'  => 'image/png',
                         '.jpg'  => 'image/jpeg',
                         '.jpeg' => 'image/jpeg',
                         '.gif'  => 'image/gif',
                         '.swf'  => 'application/x-shockwave-flash',
                         '.ico'  => 'image/x-icon' }

    cattr_reader :template_types, :asset_types
    attr_reader :theme, :localpath, :path, :fullpath
    delegate :basename, :extname, :to => :localpath

    # fullpath  - full filesystem path (used for saving etc)
    #             e.g. '/path/to/rails/themes/site-1/minimal/stylesheets/common/main.css'
    # localpath - filesystem path relative to the theme base dir (used in admin interface)
    #             e.g. 'stylesheets/common/main.css'
    # path      - absolute path with leading type like 'image' etc. (used in an image_tag, matches the theme route)
    #             e.g. 'stylesheets/themes/minimal/common/main.css'

    class << self
      def extname(path)
        '.' + ::File.basename(path).split('.')[1, 2].join('.')
      end

      def filename_pattern
        "{#{subdirs.join(',')}}/**/*"
      end

      def to_id(path)
        path = path.join('-') if path.is_a?(Array)
        path.to_s.gsub(/[\/\.]/, '-').gsub(/^-/, '')
      end

      def valid_path?(path)
        # TODO this disallows all sorts of special characters in paths. is that really appropriate?
        path.to_s !~ /[^\w\.\-\/\\\: ]/
      end
    end

    def initialize(theme, full_or_localpath = nil, data = nil)
      @theme = theme
      if full_or_localpath
        # localize path (in case a fullpath was passed) and diliberately ignore leading slashes
        @localpath = Pathname.new sanitize(full_or_localpath).sub(@theme.path, '').sub(/^\//, '')
        # rebase localpath to subdir according to file type (e.g. images, stylesheets, ...)
        @localpath = subdir.join strip_subdir(@localpath)
        @fullpath = theme.path.join(@localpath)
      end
    end

    def id
      self.class.to_id(@localpath)
    end

    def path
      @localpath.to_s.blank? ? '' : Pathname.new('/') + subdir + path_prefix + strip_subdir(@localpath)
    end

    def path_prefix
      theme.path.sub(Theme.root_dir, '').sub(/^\//, '').sub(/site-\d*\//, '')
    end

    def sanitize(path)
      # TODO anything else to sanitize a filename?
      path.to_s.gsub!(/[^\w\.\-\/]/, '_')
      path.untaint
    end

    def gsub(*args)
      self.class.new to_s.gsub(*args)
    end

    def replace(other)
      @localpath = other.localpath
      @fullpath = other.fullpath
      @data = nil
    end

    def ==(other)
      path == other.path
    end

    def <=>(other)
      path <=> other.path
    end

    def file?
      fullpath && fullpath.file?
    end

    def valid_path?
      !!(fullpath.to_s =~ /^#{theme.path.to_s}/) && self.class.valid_path?(fullpath.to_s)
    end

    def mv(path)
      FileUtils.mkdir_p ::File.dirname(path)
      FileUtils.mv fullpath, path
    end

    private

    def strip_subdir(path)
      path.sub(%r((#{self.class.subdirs.join('|')})/), '')
    end
  end
end