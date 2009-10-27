module Rbac
  class Context
    mattr_accessor :default_permissions
    self.default_permissions = {}

    class << self
      def root
        @root ||= Base.new(self)
      end
      
      def define_class(model, options)
        returning Class.new(Base) do |klass|
          model.const_set('RoleContext', klass).class_eval do
            self.parent_accessor = options.delete(:parent)
            self.options = options
          end
        end
      end
    end
    
    class Base
      class_inheritable_accessor :parent_accessor, :options, :children
      self.options  = {}
      self.children = []
      
      attr_accessor :object

      def initialize(object = nil)
        self.object = object
      end

      def authorizing_role_types_for(action)
        raise ArgumentError.new("No action given (on: #{self.inspect})") unless action
        result = self_and_parents.inject([]) do |types, context|
          types += Array(context.permissions[action.to_sym])
        end
        raise(AuthorizingRoleNotFound.new(self, action)) if result.empty?
        result
      end

      def expand_roles_for(action)
        types = build_role_types_for(action)
        contexts = self_and_parents - [Rbac::Context.root]

        contexts.collect do |context|
          types.collect { |type| type.expand(context.object) }
        end.flatten.uniq
      end

      def include?(context)
        return false unless context
        context = context.role_context unless context.is_a?(Base)
        begin 
          return true if self.object == context.object
        end while context = context.parent
        false
      end

      def self_and_parents
        [self] + (parent ? parent.self_and_parents : [])
      end

      def parent
        if parent_accessor and parent = object.send(parent_accessor)
          parent.role_context
        elsif self != Rbac::Context.root
          Rbac::Context.root # might want to return a fake domain model here
        end
      end

      protected

        def permissions
          return Rbac::Context.default_permissions if self.class == Rbac::Context::Base
          @permissions ||= (object.try(:permissions) || {}).symbolize_keys
        end

        def build_role_types_for(action)
          authorizing_role_types_for(action).collect do |type|
            Rbac::RoleType.build(type).self_and_masters
          end.flatten.compact
        end
    end
  end
end