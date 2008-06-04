class Theme
  class Asset < File    
    class << self
      def valid?(path)
        @@asset_types.keys.include?(extname(path))
      end
      
      def subdirs
        %w(images javascripts stylesheets)
      end
    end

    def valid?
      self.class.valid?(localpath) && valid_path?
      # (1..1.megabyte).include?(params[:resource].size)
    end
      
    def valid_path?
      !!(%r((#{self.class.subdirs.join('|')})/) =~ localpath) && super
    end
    
    def text?
      type != 'image'
    end

    def content_type
      @@asset_types[extname]
    end
    
    def subdir
      Pathname.new type.pluralize
    end

    def type
      case content_type
        when /image|flash/ then 'image'
        when /javascript/  then 'javascript'
        when /css/         then 'stylesheet'        
      end || ''
    end
  end
end