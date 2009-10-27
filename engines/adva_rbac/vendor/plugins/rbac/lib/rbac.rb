require 'rbac/acts_as_role_context'
require 'rbac/acts_as_role_subject'
require 'rbac/context'
require 'rbac/subject'
require 'rbac/role_type'
require 'rbac/role'

module Rbac
  class UndefinedRoleType < IndexError
    def initialize(name)
      super "Could not find role type named #{name}"
    end
  end

  class AuthorizingRoleNotFound < IndexError
    def initialize(context, action)
      super "Could not find role(s) for #{action} (on: #{context.inspect})"
    end
  end

  class NoImplementation < RuntimeError
    def initialize
      super "No implementation configured: Rbac::RoleType.implementation"
    end
  end
end