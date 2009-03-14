module TableBuilder
  class Column
    attr_reader :name, :options

    def initialize(table, name, options = {})
      @table = table
      @name = name
      @value = options.delete(:value)
      @options = options || {}
    end
    
    def value_for(record)
      @value ? @value.call(record) : record.send(attribute_name)
    end
    
    def attribute_name
      name.to_s.underscore
    end
  end
end