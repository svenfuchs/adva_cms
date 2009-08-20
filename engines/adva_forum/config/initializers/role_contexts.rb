if Rails.plugin?(:adva_rbac)
  ActionController::Dispatcher.to_prepare do
    Board.acts_as_role_context :parent => Section
    Topic.acts_as_role_context :parent => Section
  end
end