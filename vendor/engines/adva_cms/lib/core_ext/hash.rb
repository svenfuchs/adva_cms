class Hash
  def deep_symbolize_keys
    inject({}){|result, (key, value)|
      value = value.deep_symbolize_keys if value.is_a? Hash
      result[(key.to_sym rescue key) || key] = value
      result
    }
  end
  
  def deep_symbolize_keys!
    replace deep_symbolize_keys
  end
  
  def deep_compact(&block)
    block = lambda{|key, value| value.nil? } unless block_given?
    each do |key, value| 
      value = value.deep_compact(&block) if value.is_a? Hash
    end
    reject &block
  end
  
  def deep_compact!(&block)
    replace deep_compact(&block)
  end
end