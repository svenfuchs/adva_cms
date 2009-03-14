module TableBuilder
  class Table < Tag
    def self.level; 0 end

    def initialize(collection = [], options = {})
      @columns = []
      @collection = collection
      @head = Head.new(self, @columns)

      super(:table, nil, options.reverse_merge(:id => "#{collection_name}_table", :class => 'list'))
      yield(self) if block_given?
    end

    def columns(*names)
      options = names.last.is_a?(Hash) ? names.pop : {}
      names.each { |name| column(name, options) }
    end

    def column(name, options = {})
      @columns << Column.new(self, name, options)
    end

    def body(options = {}, &block)
      @body = Body.new(self, @columns, @collection, options, &block)
    end

    def collection_class
      @collection.first.class
    end

    def collection_name
      collection_class.name.tableize.gsub('/', '_')
    end

    def to_html
      auto_columns if @columns.empty?
      auto_body    if @body.nil?

      super do |html|
        html << @head.to_html if @head
        html << @body.to_html
      end.gsub(/\n\s*\n/, "\n")
    end

    protected
    
      def auto_columns
        columns(*collection_attribute_names)
      end
      
      def auto_body
        body { |row, record, index| row.cells *@columns.map { |column| column.value_for(record) } }
      end

      def collection_attribute_names
        record = @collection.first
        names = record.respond_to?(:attribute_names) ? record.attribute_names : []
        names.map(&:titleize)
      end
  end
end