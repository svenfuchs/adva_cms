class Registry < Hash
  class << self
    def instance
      @@instance ||= new
    end
    
    def get(*args)
      instance.get *args
    end
    
    def set(*args)
      instance.set *args
    end
    
    def clear
      instance.clear
    end
  end

  def initialize
    blk = lambda {|h,k| h[k] = Registry.new(&blk)}
    super &blk
  end

  def set(*args)
    value, last_key = args.pop, args.pop
    target = args.inject(self){|result, key| result[key] }
    value = to_registry(value) if value.is_a?(Hash)
    target[last_key] = value
  end

  def get(*keys)
    keys.inject self do |result, key| 
      return nil unless result.has_key?(key)
      result[key]
    end
  end
  
  protected
  
    def to_registry(hash)
      registry = Registry.new
      hash.each do |key, value|
        value = to_registry(value) if value.is_a?(Hash)
        registry[key] = value
      end
      registry
    end
end
