ActionController::Dispatcher.to_prepare do
  Section.class_eval do
    def update_url_history_params(params)
      params[:action] = 'index' if single_article_mode && params[:controller] == 'articles' && params[:action] == 'show'

      if params.has_key?(:permalink)
        params.merge(:permalink => self.permalink)
      else
        params
      end
    end
  end
end

