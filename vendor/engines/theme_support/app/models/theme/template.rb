class Theme
  class Template < File
    class << self
      def valid?(path)
        @@template_types.keys.include?(extname(path))
      end
      
      def subdirs
        %w(templates)
      end
    end
    
    def text?
      true
    end

    def valid?
      self.class.valid?(localpath) && valid_path?
    end
      
    def valid_path?
      !!(%r((#{self.class.subdirs.join('|')})/) =~ localpath) && super
    end
    
    def extname
      ext = basename.to_s.split('.')
      ext.shift
      '.' + ext.join('.')
    end
    
    def subdir
      Pathname.new type.pluralize
    end
    
    def type
      'template'
    end
  end
end