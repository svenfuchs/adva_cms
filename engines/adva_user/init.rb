ActionController::Base.send :include, ActionController::AuthenticateUser
ActionController::Base.send :include, ActionController::AuthenticateAnonymous
ActionController::Base.send :include, ActionController::GuardsPermissions

ActiveRecord::Base.send :include, ActiveRecord::ActsAsRoleContext
ActiveRecord::Base.send :include, ActiveRecord::BelongsToAuthor

ActionView::Base.send :include, Login::HelperIntegration

# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

# ActiveSupport::Inflector.inflections_without_route_reloading do |inflect|
#   inflect.singular 'Anonymous', 'Anonymous'
#   inflect.singular 'anonymous', 'anonymous'
#   inflect.irregular 'anonymous', 'anonymouses'
# end

Event.observers << UserMailer
Event.observers << PasswordMailer


