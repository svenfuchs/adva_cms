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

  def deep_compact!(&block)
    block = lambda{|key, value| value.nil? } unless block_given?
    each{|key, value| store key, value.deep_compact!(&block) if value.is_a? Hash }
    reject! &block
    self
  end
end
