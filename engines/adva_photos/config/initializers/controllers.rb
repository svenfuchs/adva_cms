ActionController::Dispatcher.to_prepare do
  Admin::BaseController.helper :"admin/photos"
end

