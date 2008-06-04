module Stubby
  class Definition
    attr_reader :name, :class, :original_class, :base_class, :methods
    attr_accessor :default_instance_key
    
    def initialize(attributes = {})
      attributes.each{|name, value| instance_variable_set :"@#{name}", value }
      register
    end
    
    def register
      if base_class == Base
        Stubby.base_definitions[key] = self
      else
        base_definition.default_instance_key ||= instance_key
        Stubby.instance_definitions(base_key)[instance_key] = self
      end
    end
    
    def name
      @name ||= original_class.name if original_class
      @name
    end
    
    def base_class
      @base_class ||= Base
    end
    
    def base_key
      @base_key ||= base_class.name.demodulize
    end
    
    def base_definition
      @base_definition ||= Stubby.base_definitions[base_key]
    end
    
    def key
      @key ||= name.to_s.classify.sub('::', '')
    end
    
    def instance_key
      @instance_key ||= name.demodulize.underscore.to_sym
    end
    
    def original_class
      @original_class ||= base_class.original_class if base_class
      @original_class
    end
    
    def methods
      @methods ||= {}
    end
    
    def create!(&block)
      @class = ClassFactory.create(base_class, name, original_class, methods, &block)
    end
      
    def instantiate(key = nil)
      if key == :all
        instance_definitions.collect{|key, definition| definition.instantiate }
      elsif key
        key = default_instance_key if key == :first
        instance_definition(key).instantiate
      else
        Instances.by_key(base_class)[instance_key] or
        Instances.store(base_class, self.class.new, instance_key)
      end
    end

    def instance_definitions
      Stubby.instance_definitions(key)
    end
    
    def instance_definition(instance_key)
      Stubby.instance_definitions(key)[instance_key]
    end
  end  
end