module ActiveRecord
  module ActsAsRoleContext
    def self.included(base)
      base.extend ActMacro  
    end

    module ActMacro
      def acts_as_role_context(options = {})
        return if acts_as_role_context?
        
        include InstanceMethods
        extend ClassMethods

        class_inheritable_accessor :roles, :default_permissions
        self.roles = Array(options[:roles]).compact
        self.default_permissions = {}
        
        if options[:implicit_roles]
          define_method(:implicit_roles, &options[:implicit_roles]) 
        end
      end

      def acts_as_role_context?
        included_modules.include?(ActiveRecord::ActsAsRoleContext::InstanceMethods)
      end
    end
    
    module InstanceMethods
      def role_context(role)
        self.class.roles.include?(role) ? self : owner && owner.role_context(role)
      end
  
      def role_authorizing(action, type = nil)
        type ||= self.class.name.demodulize.downcase.to_sym
        role = permissions[type][action] if respond_to?(:permissions) && permissions[type] 
        returning Role.build(role, self) || owner && owner.role_authorizing(action, type) do |role|
          raise "could not find role for #{type}: #{action}" unless role
          role.original_context = self
        end
      end
  
      def permissions
        @permissions ||= begin
          roles = read_attribute(:permissions) || {}
          self.class.default_permissions.update roles # TODO needs a deep merge?
        end
      end
    end
    
    module ClassMethods
      def permissions(values)
        self.default_permissions = PermissionMap.new values
      end
    end
  end
end