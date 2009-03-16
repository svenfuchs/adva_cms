module TableBuilder
  class Row < Tag
    self.level = 2
    self.tag_name = :tr
    
    def initialize(parent, record = nil, options = {}, &block)
      super(parent, options)

      @parent = parent
      @cells = []
      @block = block

      yield(*[self, record].compact) if block_given?
    end

    def cell(*contents)
      options = contents.last.is_a?(Hash) ? contents.pop : {}
      add_class!(options, current_column_class) if parent.is_a?(Body)
      contents.each do |content|
        @cells << Cell.new(self, content, options)
      end
    end

    def render
      super(@cells.map(&:render))
    end
    
    protected
    
      def alternate(options)
        options[:class] ||= ''
        options[:class] = options[:class].split(' ').push('alternate').join(' ')
      end
      
      def current_column_class
        column = table.columns[@cells.size]
        column && column.options[:class] || '' 
      end
  end
end