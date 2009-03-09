class Hash
  unless method_defined?(:symbolize_keys)
    def symbolize_keys
      inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end
  end
  
  unless method_defined?(:dasherize_keys)
    def dasherize_keys
      inject({}) do |options, (key, value)|
        options[key.to_s.gsub(/_/, '-')] = value
        options
      end
    end
  end

  unless method_defined?(:to_query) && method(:to_query).arity == -1
    def to_query(namespace=nil)
      collect do |key, value|
        value.to_query(namespace ? "#{namespace}[#{key}]" : key)
      end.sort * '&'
    end
  end
end

class Array
  unless method_defined?(:to_query) && method(:to_query).arity == -1
    def to_query(key)
      collect { |value| value.to_query("#{key}[]") } * '&'
    end
  end
end