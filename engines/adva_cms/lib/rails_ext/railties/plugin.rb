# - keep track of plugins in Rails.plugins
# - allow engines to ship their own vendor/plugins
# - add observers to plugin.app_paths
# - add an alias to register_[asset]_expansion to plugins
Rails::Configuration.class_eval do
  def default_plugin_loader
    Rails::Plugin::RegisteringLoader
  end
  
  def default_plugin_locators
    locators = []
    locators << Rails::Plugin::GemLocator if defined? Gem
    locators << Rails::Plugin::NestedFileSystemLocator
  end
end

module Rails
  class << self
    def plugins
      @@plugins ||= ActiveSupport::OrderedHash.new
    end
  
    def plugin?(name)
      plugins.keys.include?(name.to_sym)
    end
  end

  class Plugin
    class RegisteringLoader < Rails::Plugin::Loader # ummm, what's a better name?
      def register_plugin_as_loaded(plugin)
        Rails.plugins[plugin.name.to_sym] = plugin
        super
      end
    end
  
    def app_paths
      ['models', 'helpers', 'observers'].map { |path| File.join(directory, 'app', path) } << controller_path << metal_path
    end
  
    def register_javascript_expansion(*args)
      ActionView::Helpers::AssetTagHelper.register_javascript_expansion *args
    end
  
    def register_stylesheet_expansion(*args)
      ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion *args
    end
    
    class NestedFileSystemLocator < FileSystemLocator
      def locate_plugins_under(base_path)
        plugins = super
        Dir["{#{plugins.map(&:directory).join(',')}}/vendor/plugins"].each do |path|
          plugins.concat super(path)
        end unless plugins.empty?
        plugins
      end
    end
  end
end
