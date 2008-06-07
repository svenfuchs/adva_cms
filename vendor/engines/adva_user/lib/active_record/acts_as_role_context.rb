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
        self.roles = Array(options[:roles]) || []
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
        end
      end
  
      def permissions
        @permissions ||= begin
          roles = read_attribute(:permissions) || {}
          self.class.default_permissions.update roles.symbolize_keys # TODO deep merge?
        end
      end
    end
    
    module ClassMethods
      def default_actions
        [:show, :create, :update, :delete]
      end
      
      # Sets the given values to the default_permissions hash.
      #
      # Ensures the given actions are arrays, invert the role => action hash
      # to a action => role hash while expanding the actions array to keys,
      # and expand the action key :all to the default actions.
      #
      # I.e. :comment => {:user => :create, :admin => [:edit, :delete]}
      # becomes :comment => {:create => :user, :edit => :admin, :delete => :admin}        
      def permissions(values)
        values.clone.each do |type, roles| 
          roles.each do |role, actions|
            actions = actions == :all ? default_actions.dup : Array(actions)
            set_default_permissions type, Hash[*(actions.zip [role] * actions.size).flatten]
          end
        end
      end
      
      def set_default_permissions(type, permissions)
        self.default_permissions[type] ||= {}
        self.default_permissions[type].update permissions
      end
    end
  end
end