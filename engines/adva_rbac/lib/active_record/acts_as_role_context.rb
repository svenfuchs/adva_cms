module ActiveRecord
  module ActsAsRoleContext
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def acts_as_role_context(options = {})
        return if acts_as_role_context?

        include InstanceMethods
        
        serialize :permissions
        cattr_accessor :role_context_class

        self.role_context_class = if Rbac::Context.const_defined?(self.name) # TODO doesn't work with namespaced models
          "Rbac::Context::#{self.name}".constantize
        else
          Rbac::Context.create_class(self.name, options.delete(:parent), options)
        end
        
        # if options[:implicit_roles]
        #   define_method(:implicit_roles, &options[:implicit_roles])
        # end
      end

      def acts_as_role_context?
        included_modules.include?(ActiveRecord::ActsAsRoleContext::InstanceMethods)
      end
    end

    module InstanceMethods
      delegate :role_authorizing, :to => :role_context
      
      def role_context
        @role_context ||= self.role_context_class.new self
      end
      
      def permissions
        read_attribute(:permissions) || {}
      end
    end
  end
end