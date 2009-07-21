ActiveSupport::Dependencies.load_once_paths << lib_path

ActionController::Base.send :include, ActionController::AuthenticateUser
ActionController::Base.send :include, ActionController::AuthenticateAnonymous
ActiveRecord::Base.send :include, ActiveRecord::BelongsToAuthor
ActionView::Base.send :include, Login::HelperIntegration

Event.observers << 'UserMailer'
Event.observers << 'PasswordMailer'


