module Rbac
  module ActsAsRoleSubject
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def acts_as_role_subject(options = {})
        return if acts_as_role_subject?

        include InstanceMethods

        serialize :permissions
        cattr_accessor :role_subject_class

        self.role_subject_class = begin
          "#{self.name}::RoleSubject".constantize
        rescue NameError
          Rbac::Subject.define_class(self, options)
        end
      end

      def acts_as_role_subject?
        included_modules.include?(Rbac::ActsAsRoleContext::InstanceMethods)
      end
    end

    module InstanceMethods
      # returns the role subject wrapper associated to the domain object (e.g. User)
      def role_subject
        @role_subject ||= self.role_subject_class.new(self)
      end

      def has_role?(*args)
        role_subject.has_role?(*args)
      end

      def has_global_role?(type, site = nil)
        return self.roles.all.any? do |role|
          (role.name == "superuser" && type == :superuser ||
          role.name == type.to_s && role.context_type == "Site" && role.context_id == site.id)
        end
      end

      def has_permission_for_admin_area?(site)
        permitted_roles = [:superuser, :admin, :moderator, :author, :designer]
        return self.roles.all.any? do |role|
          permitted_roles.any? do |permitted_role|
            self.has_global_role?(permitted_role, site)
          end
        end
      end

      def has_permission?(*args)
        role_subject.has_permission?(*args)
      end

      def has_explicit_role?(*args)
        role_subject.has_explicit_role?(*args)
      end
    end
  end
end

ActiveRecord::Base.send(:include, Rbac::ActsAsRoleSubject)