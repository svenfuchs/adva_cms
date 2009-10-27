if Rails.plugin?(:adva_rbac)
  ActionController::Dispatcher.to_prepare do
    CalendarEvent.acts_as_role_context :parent => :section
  end
end