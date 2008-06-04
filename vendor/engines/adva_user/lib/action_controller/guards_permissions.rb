module ActionController
  class RoleRequired < SecurityError
    def initialize(role)
      super Role.definition(role).role_required_message
    end
  end
  
  module GuardsPermissions
    def self.included(base)
      base.extend ClassMethods
    end
  
    module ClassMethods
      def guards_permissions(options)
        return if guards_permissions?        
        include InstanceMethods
        
        options = {options => {}} unless options.is_a? Hash
        options.each do |permission, options|
          before_filter(options){|controller| controller.guard_permission permission }
        end
      end
      
      def guards_permissions?
        included_modules.include? InstanceMethods
      end
    end
    
    module InstanceMethods    
      def guard_permission(permission)    
        unless has_permission?(permission)
          role = target_for_permission_guarding.required_role_for(permission)
          raise RoleRequired.new role
        end
      end
      
      def has_permission?(permission)
        user = current_user || Anonymous.new
        object = target_for_permission_guarding
        unless role = object.required_role_for(permission)
          raise "could not find role for #{permission} on #{object}"
        end
        user.has_role? role, object
      end
    end
  end
end