module Stubby
  class HasManyProxy < Array
    attr_accessor :name
  
    def initialize(name, values, methods)
      @name = name
      @values = values
      define_methods methods
    end
    
    def resolve
      if @values.respond_to?(:resolve)
        replace @values.resolve
      else
        replace @values.collect{|object| object.resolve if object.respond_to?(:resolve) }
      end
    end
  
    def define_methods(methods)
      methods.each do |names, value| 
        Array(names).each{|name| define_method name, value}
      end
    end
  
    def define_method(name, value)
      (class << self; self; end).send :define_method, name do |*args|
        @__values ||= {}
        @__values[name] ||= value.respond_to?(:resolve) ? value.resolve : value
      end
    end
  
    def inspect
      "<HasManyProxy:#{name.to_s.camelize}:#{object_id} #{super}>"
    end
    alias :to_s :inspect
  end
end    