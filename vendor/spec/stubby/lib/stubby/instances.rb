module Stubby
  module Instances
    class InstanceNotFound < RuntimeError; end
    
    class << self  
      def lookup(klass, key = nil)
        if (singular = klass.singularize) != klass
          klass = singular
          method = :find_all
          key ||= :all
        else
          method = :find_one
          key ||= :first
        end
        method = :find_all if key == :all

        definition = Stubby.base_definition(klass.classify) or raise "could not find base_definition for #{klass.classify}"
        send(method, definition, key)
      end 
      
      def find_all(definition, key)
        key = nil if key == :all
        if key
          [find_one(definition, key)].compact
        else
          definition.instantiate(:all) unless complete[definition.class]
          complete[definition.class] = true
          by_class(definition.class)
        end
      end
    
      def find_one(definition, key)
        key = definition.default_instance_key if key == :first
        by_key(definition.class)[key] || definition.instantiate(key)
      end
      
      def by_class(klass)
        @by_class ||= {}
        @by_class[klass] ||= []
      end
  
      def by_key(klass)
        @by_key ||= {}
        @by_key[klass] ||= {}
      end
      
      def complete
        @complete ||= {}
      end
      
      def store(klass, object, key)
        by_class(klass) << object
        by_key(klass)[key] = object
      end
      
      def clear!
        @by_class = {}
        @by_key = {}
        @complete = {}
      end
    end
  end
end