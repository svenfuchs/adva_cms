if Rails.plugin?(:adva_rbac)
  ActionController::Dispatcher.to_prepare do
    Comment.acts_as_role_context :parent => :commentable
  end
end