module Rbac
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

        self.role_context_class = begin
          "#{self.name}::RoleContext".constantize
        rescue NameError
          Rbac::Context.define_class(self, options)
        end
      end

      def acts_as_role_context?
        included_modules.include?(Rbac::ActsAsRoleContext::InstanceMethods)
      end
    end

    module InstanceMethods
      delegate :authorizing_role_types_for, :to => :role_context
      
      # returns the role context wrapper associated to the domain object (e.g. Site)
      def role_context
        @role_context ||= self.role_context_class.new(self)
      end
      
      # attribute reader that returns a hash as a default
      def permissions
        read_attribute(:permissions) || {}
      end
    end
  end
end

ActiveRecord::Base.send(:include, Rbac::ActsAsRoleContext)