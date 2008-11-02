class Theme
  class File < Path
    class << self
      def build(theme, path, data = nil)
        [Theme::Other, Theme::Asset, Theme::Template].each do |klass|
          return klass.new(theme, path, data) if klass.valid?(path)
        end
        # TODO raise something more meaningful
        raise "Can't build file #{path} because it seems to be neither a valid asset nor valid template path."
      end

      def upload(theme, files)
        files = [files] unless files.is_a? Array
        files.collect do |file|
          file = build theme, file.original_filename.gsub(/^.*(\\|\/)/, ''), file.read
          file.save
          file
        end
      end

      def create(theme, options)
        if options[:data].is_a? String
          file = build theme, options[:localpath], options[:data]
          file.save ? file : false
        else
          upload theme, options[:data]
        end
      end
    end

    attr_accessor :errors

    def initialize(theme = nil, full_or_localpath = nil, data = nil)
      @data = data
      @errors = []
      super
    end

    def update_attributes(attrs)
      attrs.symbolize_keys!
      @data = attrs[:data]
      returning save do
        rename attrs[:localpath]
      end
    end

    def text?
      true
    end

    def data
      @data ||= read
    end

    def read
      ::File.open(fullpath) {|f| f.read } if file?
    end

    def save
      return false unless valid?
      mkdir
      ::File.open(fullpath, 'wb') { |f| f.write @data }
      true
    end

    def valid?
      true # TODO implement
    end

    def mkdir
      FileUtils.mkdir_p fullpath.dirname.to_s
    end

    def destroy
      fullpath.unlink
      true
    rescue Exception => e
      errors << e.message
      false
    end

    def rename(path)
      unless path.blank? || path == localpath
        to = self.class.new @theme, path
        raise "invalid filename \"#{path}\"" unless to.valid?
        to.mkdir
        fullpath.rename to.fullpath # TODO raise if file exists
        replace to
      end
    end
  end
end