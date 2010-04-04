ActionController::Dispatcher.to_prepare do
  Site.class_eval do
    has_many :invitations
  end
end