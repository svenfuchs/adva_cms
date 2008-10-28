require 'core_ext/object_try'

require 'rbac/context'
require 'rbac/role'
require 'active_record/acts_as_role_context'

ActiveRecord::Base.send :include, ActiveRecord::ActsAsRoleContext
Rbac::Role.define :foo
