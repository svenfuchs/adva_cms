class LambdaTable
  @@table = Hash.new
  
  def self.register(key, method)
    @@table[key] = method
  end
  
  def self.lookup(key)
    @@table[key]
  end
end
