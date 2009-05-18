I18n.load_path += Dir[File.dirname(__FILE__) + '/config/locales/*.{yml,rb}']

config.to_prepare do
  BaseController.helper :meta_tags
  Admin::BaseController.helper :meta_tags
end