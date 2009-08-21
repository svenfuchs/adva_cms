ActionController::Dispatcher.to_prepare do
  Content.class_eval do
    def update_url_history_params(params)
      if params.has_key?(:year)
        params.merge(self.full_permalink)
      elsif params.has_key?(:permalink)
        params.merge(:permalink => self.permalink)
      else
        params
      end
    end
  end
end

