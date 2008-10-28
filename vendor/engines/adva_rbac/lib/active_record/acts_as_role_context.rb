module ActiveRecord
  module ActsAsRoleContext
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def acts_as_role_context(options = {})
        return if acts_as_role_context?

        include InstanceMethods
        # extend ClassMethods
        
        serialize :permissions
        
        cattr_accessor :role_context_class

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

      def acts_as_role_context?
        included_modules.include?(ActiveRecord::ActsAsRoleContext::InstanceMethods)
      end
    end

    module InstanceMethods
      def role_context
        @role_context ||= self.role_context_class.new self
      end
      
      delegate :role_authorizing, :to => :role_context
      
      def permissions
        read_attribute(:permissions) || {}
      end
    end
  end
end