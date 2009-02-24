ActionController::Dispatcher.to_prepare do
  Site.class_eval do
    def has_tracking_enabled?
      !google_analytics_tracking_code.blank?
    end
  end
end