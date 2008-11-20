begin
  require 'rails/version'
  unless Rails::VERSION::MAJOR >= 2 && Rails::VERSION::MINOR >= 1 && Rails::VERSION::TINY >= 1
    raise "This version of the engines plugin requires Rails 2.1.1 or later!"
  end
end

require File.join(File.dirname(__FILE__), 'lib/engines')

# initialize Rails::Configuration with our own default values to spare users 
# some hassle with the installation and keep the environment cleaner

{ :default_plugin_locators => [Engines::Plugin::FileSystemLocator],
  :default_plugin_loader => Engines::Plugin::Loader,
  :default_plugins => [:engines, :all] }.each do |name, default|    
  Rails::Configuration.send(:define_method, name) { default }
end