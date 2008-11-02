class Theme
  class Other < File
    class << self
      def valid?(path)
        ['preview.png'].include?(path.to_s)
      end

      def subdirs
        ['images']
      end

      def filename_pattern
        "*"
      end

      def default_preview(theme, path)
        # bypass the default path setting to allow an exceptional fullpath
        # outside of the theme directory
        returning new(theme) do |file|
          {:@localpath => 'preview.png', :@fullpath  => path}.each do |name, path|
            file.instance_variable_set name, Pathname.new(path)
          end
        end
      end
    end

    def valid?
      self.class.valid?(basename) && valid_path?
    end

    def text?
      false
    end

    def content_type
      @@asset_types[extname]
    end

    def path
      Pathname.new('/images' + super)
    end

    def subdir
      Pathname.new ''
    end

    # def type
    #   image? ? 'image' : ''
    # end
  end
end