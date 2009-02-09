module OutputFilter
  class Cells
    class SimpleParser
      def cells(html)
        html.scan(/(<cell [^>]*\/>)/m).inject({}) do |cells, matches|
          tag = matches.first
          attrs = parse_attributes(tag)
          name, state = attrs.delete('name').split('/')
          cells[tag] = [name, state, attrs]
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
      if controller.response.body.is_a?(String)
        cells = parser.cells(controller.response.body)
        controller.response.body.gsub!(/(#{cells.keys.join('|')})/) do |tag|
          controller.response.template.render_cell *cells[tag]
        end unless cells.empty?
      end
    end

    protected
      def parser
        @parser ||= self.class.parser.new
      end
  end
end