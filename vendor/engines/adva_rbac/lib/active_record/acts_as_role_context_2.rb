module ActiveRecord
  module ActsAsRoleContext2
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def acts_as_role_context_2(options = {})
        return if acts_as_role_context_2?

        include InstanceMethods
        # extend ClassMethods
        
        class_inheritable_accessor :role_context_class

        parent = options[:parent]
        parent_class = parent.try(:role_context_class) || Rbac::Context::Base
        
        options.update :parent => parent.name.underscore.to_sym if parent
        
        self.role_context_class = Class.new(parent_class)
        Rbac::Context.const_set(self.name, self.role_context_class).class_eval do
          self.options = options
        end
        
        # if options[:implicit_roles]
        #   define_method(:implicit_roles, &options[:implicit_roles])
        # end
      end

      def acts_as_role_context_2?
        included_modules.include?(ActiveRecord::ActsAsRoleContext2::InstanceMethods)
      end
    end

    module InstanceMethods
      def role_context #(role)
        @role_context ||= self.role_context_class.new self
        # self.class.roles.include?(role) ? self : owner && owner.role_context(role)
      end

      # def role_authorizing(action, type = nil)
      #   type ||= self.class.name.demodulize.downcase.to_sym
      #   role = permissions[type][action] if respond_to?(:permissions) && permissions[type]
      #   returning Role.build(role, self) || owner && owner.role_authorizing(action, type) do |role|
      #     raise "could not find role for #{type}: #{action} (on: #{self.inspect})" unless role
      #     role.original_context = self
      #   end
      # end
      
      delegate :role_authorizing, :to => :role_context
      
      def permissions
        @permissions ||= {} # TODO read_attribute(:permissions) || {}
      end
    end

    # module ClassMethods
    #   def permissions(values)
    #     self.default_permissions = PermissionMap.new values
    #   end
    # end
  end
end