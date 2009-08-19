ActionController::Dispatcher.to_prepare do
  BaseController.class_eval { helper :users }
  Admin::BaseController.class_eval { helper :users, :'admin/users' }
end