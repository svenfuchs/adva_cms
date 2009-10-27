module Rbac
  class Subject
    class << self
      def define_class(model, options)
        returning Class.new(Base) do |klass|
          model.const_set('RoleSubject', klass)
        end
      end
    end

    class Base
      attr_accessor :object

      def initialize(object = nil)
        self.object = object
      end

      def has_permission?(action, context)
        # puts "============== action = #{action}"
        # puts "============== context = #{context}"
        types = context.authorizing_role_types_for(action)
        # puts "============== authorizing_role_types_for #{types}"
        has_role?(types, context)
      end

      def has_role?(types, context = nil)
        Array(types).any? do |type|
          type = Rbac::RoleType.build(type) unless type.respond_to?(:granted_to?)
          type.granted_to?(self, context)
        end
      end

      def has_explicit_role?(type, context = nil)
        type = Rbac::RoleType.build(type) unless type.respond_to?(:granted_to?)
        type.granted_to?(self, context, :explicit => true)
      end

      def ==(other)
        super || object == other # hmmmm ...
      end

      def respond_to?(method)
        object.respond_to?(method) || super
      end

      def method_missing(method, *args, &block)
        return object.send(method, *args, &block) if object.respond_to?(method)
        super
      end
    end
  end
end
