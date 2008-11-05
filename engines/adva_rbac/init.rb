require 'active_record/acts_as_role_context'

ActiveRecord::Base.send :include, ActiveRecord::ActsAsRoleContext

require 'action_controller/dispatcher'
ActionController::Dispatcher.to_prepare do
  # defer this to after config/initializer stage so people can redefine roles
  Rbac.initialize!
end