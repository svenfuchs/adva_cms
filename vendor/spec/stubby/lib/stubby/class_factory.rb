module Stubby
  class ClassFactory # too bad, we can't extend ::Class
    class << self
      def create(base_class, *args, &block)
        klass = new(base_class, *args, &block).klass
      end
    end
    
    attr_reader :klass
    
    def initialize(base_class, name, original_class, methods = {}, &block)      
      @klass = ::Class.new(base_class)
      target = base_class == Stubby::Base ? Stubby::Classes : base_class
      target.const_set name.sub('::', ''), @klass
      
      @klass.original_class = original_class
      define_methods methods
      instance_eval &block if block
    end
    
    def has_many(names, *args)
      methods = args.extract_options!
      Array(names).each do |name|
        values = args.last || lookup(name, :all)
        as = methods.delete(:_as) || name
        proxy = Handle.new{ HasManyProxy.new name, values, methods }
        define_method (as || name), proxy
      end
    end
    
    def has_one(names, object = nil)
      Array(names).each do |name|
        object ||= lookup(name, :first)
        define_method name, object
      end
    end
    
    def belongs_to(names, object = nil)
      Array(names).each do |name|
        object ||= lookup(name, :first)
        define_method name, object
        define_method :"#{name}_id", Handle.new{ object.resolve.id }
      end
    end
    
    def instance(*args)
      definition = Definition.new :base_class => @klass, 
                                  :methods => args.extract_options!, 
                                  :name => args.shift.to_s.camelize
      definition.create!                            
    end
    
    def lookup(key, *args)
      Handle.new{ Stubby::Instances.lookup(key.to_s, *args) }
    end
      
    def method_missing(name, *args)
      return lookup($1, *args) if name.to_s =~ /^stub_(.*)/
      super
    end
    
    def define_methods(methods)
      methods.each do |names, value| 
        Array(names).each{|name| define_method name, value}
      end
    end
    alias :methods :define_methods
    
    def define_method(name, value)
      @klass.send :define_method, name do |*args|
        @__values ||= {}
        @__values[name] ||= value.respond_to?(:resolve) ? value.resolve : value
      end
    end
  end
end