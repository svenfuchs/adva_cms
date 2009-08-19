ActionController::Dispatcher.to_prepare do
  BaseController.class_eval { helper :blog }
end
