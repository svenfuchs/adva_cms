ActionController::Dispatcher.to_prepare do
  Section.delegate :spam_engine, :to => :site
end
