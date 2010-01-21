ActionController::Dispatcher.to_prepare do
  BaseController.class_eval do
    acts_as_themed_controller :current_themes => lambda {|c| c.site.themes.active if c.site }
    # :force_template_types => ['html.serb', 'liquid']
    # :force_template_types => lambda {|c| ['html.serb', 'liquid'] unless c.class.name =~ /^Admin::/ }
  end
    
  Admin::BaseController.helper :themes

  ActionController::Base.class_eval do
    def expire_site_page_cache_with_theme_asset_clearing
      expire_site_page_cache_without_theme_asset_clearing
      @site.themes.each { |theme| theme.clear_asset_cache! }
    end
    alias_method_chain :expire_site_page_cache, :theme_asset_clearing
  end
end

