module TableBuilder
  class Head < Tag
    def self.level; 1 end

    attr_reader :columns

    def initialize(parent = nil, *columns)
      options = columns.last.is_a?(Hash) ? columns.pop : {}
      super(:thead, parent, options)

      columns = columns.first if columns.first.is_a?(Array)
      @columns = columns
    end

    def to_html
      row = Row.new(self, columns, 0, options)
      columns.each do |column| 
        content = column.name 
        content = I18n.t(content, :scope => i18n_scope) if content.is_a?(Symbol)
        row.cell(content, column.options.reverse_merge(:scope => 'col'))
      end
      super(row.to_html)
    end
    
    protected

      def i18n_scope
        [TableBuilder.options[:i18n_scope], table.collection_name, :columns].compact if table
      end
  end
end