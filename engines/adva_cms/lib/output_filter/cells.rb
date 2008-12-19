module OutputFilter
  class Cells
    class SimpleParser
      def cells(html)
        html.scan(/(<cell [^>]*\/>)/m).inject({}) do |cells, matches|
          tag = matches.first
          attrs = parse_attributes(tag)
          controller, name = attrs.delete('controller'), attrs.delete('name')
          cells[tag] = [controller, name, attrs]
          cells
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
      cells = parser.cells(controller.response.body)
      pattern = /(#{cells.keys.join('|')})/
      controller.response.body.gsub!(pattern) do |tag|
        controller.response.template.render_cell *cells[tag]
      end
    end
    
    protected
      def parser
        @parser ||= self.class.parser.new
      end
  end
end