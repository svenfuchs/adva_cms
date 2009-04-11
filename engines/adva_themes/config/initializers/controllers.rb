ActionController::Dispatcher.to_prepare do
  BaseController.class_eval do
    acts_as_themed_controller :current_themes => lambda {|c| c.site.themes.active if c.site }
    # :force_template_types => ['html.serb', 'liquid']
    # :force_template_types => lambda {|c| ['html.serb', 'liquid'] unless c.class.name =~ /^Admin::/ }
  end
    
  Admin::BaseController.helper :themes
end

