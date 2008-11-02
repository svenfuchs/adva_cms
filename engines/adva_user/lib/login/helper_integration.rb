module Login
  # Automatically mixed into all views for utility functions.
  module HelperIntegration

    # Returns the current user at the view level. Everything said
    # about the current_user method in the
    # Login::ControllerIntegration::InstanceMethods module
    # applies to this method as well.
    def current_user; controller.current_user end
  end
end