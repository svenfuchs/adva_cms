ActionController::Dispatcher.to_prepare do
  Admin::ArticlesController.class_eval do
    cache_sweeper :article_ping_observer, :only => [:create, :update]
  end
end