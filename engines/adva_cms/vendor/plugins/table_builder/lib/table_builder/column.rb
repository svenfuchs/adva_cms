module TableBuilder
  class Column
    attr_reader :name, :options

    def initialize(table, name, options = {})
      @table = table
      @name = name
      @value = options.delete(:value)
      @options = options.dup || {}
      @options[:class] ||= name
    end
    
    def content
      name.is_a?(Symbol) ? translate(name) : name
    end

    def translate(content)
      scope = [TableBuilder.options[:i18n_scope], @table.collection_name, :columns].compact
      I18n.t(content, :scope => scope)
    end
    
    def attribute_name
      name.to_s.underscore
    end
  end
end