config.to_prepare do
  BaseController.helper :meta_tags
  Admin::BaseController.helper :meta_tags
end