Rails::Initializer.class_eval do
  def load_application_initializers_with_plugin_initializers
    if gems_dependencies_loaded
      plugin_loader.load_plugin_initializers 
    end
    load_application_initializers_without_plugin_initializers
  end
  alias_method_chain :load_application_initializers, :plugin_initializers
end

Rails::Plugin::Loader.class_eval do
  def load_plugin_initializers
    plugins.each do |plugin| 
      plugin.load_plugin_initializers if plugin.engine?
    end
  end
end

Rails::Plugin.class_eval do
  def load_plugin_initializers
    Dir["#{directory}/config/initializers/**/*.rb"].sort.each do |initializer|
      Kernel.load(initializer)
    end
  end
end