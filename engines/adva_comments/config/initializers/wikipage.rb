ActionController::Dispatcher.to_prepare do
  Wikipage.class_eval do
    has_many_comments :polymorphic => true

    delegate :accept_comments?, :to => :section
  end
end