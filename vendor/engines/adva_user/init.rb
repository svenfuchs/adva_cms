ActionController::Base.send :include, ActionController::AuthenticateUser
ActionController::Base.send :include, ActionController::AuthenticateAnonymous
ActionController::Base.send :include, ActionController::GuardsPermissions

ActiveRecord::Base.send :include, ActiveRecord::ActsAsRoleContext
ActiveRecord::Base.send :include, ActiveRecord::BelongsToAuthor

ActionView::Base.send :include, Login::HelperIntegration

# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

