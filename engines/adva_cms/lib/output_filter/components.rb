module OutputFilter
  class Components
    class SimpleParser
      def components(html)
        html.scan(/(<component [^>]*\/>)/m).inject({}) do |components, matches|
          tag = matches.first
          attrs = parse_attributes(tag)
          # controller, name = attrs.delete('controller'), attrs.delete('name')
          # components[tag] = ["#{controller}/#{name}", attrs]
          name = attrs.delete('name')
          components[tag] = [name, attrs]
          components
        end
      end
      
      protected
        def parse_attributes(str)
          html = /(\w+)=(?:'|")([^'"]*)(?:'|")/miu
          Hash[*str.scan(html).flatten]
        end
    end
    
    class << self
      def parser
        # TODO could check for hpricot here and use a different implementation
        @@parser ||= SimpleParser 
      end
      
      def parser=(parser)
        @@parser = parser
      end
    end

    def before(controller) end
      
    def after(controller)
      components = parser.components(controller.response.body)
      pattern = /(#{components.keys.join('|')})/
      controller.response.body.gsub!(pattern) do |tag|
        controller.response.template.component *components[tag]
      end unless components.empty?
    end
    
    protected
      def parser
        @parser ||= self.class.parser.new
      end
  end
end