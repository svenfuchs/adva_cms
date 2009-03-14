module TableBuilder
  class Body < Tag
    include ActionController::RecordIdentifier
    include ActionView::Helpers::RecordIdentificationHelper
    
    def self.level; 1 end

    attr_reader :columns, :collection, :block

    def initialize(parent = nil, columns = [], collection = [], options = {}, &block)
      super(:tbody, parent, options)
      @columns = columns
      @collection = collection
      @block = block
    end

    def to_html
      super do |html|
        collection.each_with_index do |record, index|
          row = Row.new(self, columns, index, options_for_record(record))
          block.call(row, record, index)
          html << row.to_html
        end
      end
    end
    
    protected
    
      def options_for_record(record)
        options = {}
        options[:id] = dom_id(record) if record.respond_to?(:new_record?)
        options
      end
  end
end