module TableBuilder
  class Row < Tag
    def self.level; 2 end

    def initialize(parent = nil, columns = [], index = 0, options = {})
      add_class!(options, 'alternate') if index % 2 == 1
      super(:tr, parent, options)

      @parent = parent
      @columns = columns
      @index = index
      @cells = []
    end
    
    def cells(*contents)
      contents.each do |content| cell(content) end
    end

    def cell(content, options = {})
      add_class!(options, current_column_class) if parent.is_a?(Body)
      @cells << Cell.new(self, content, options)
    end

    def to_html
      super(@cells.map(&:to_html))
    end
    
    protected
    
      def alternate(options)
        options[:class] ||= ''
        options[:class] = options[:class].split(' ').push('alternate').join(' ')
      end
      
      def current_column_class
        @columns[@cells.count].options[:class] || ''
      end
  end
end