Rails::Initializer.configure do |config|
  config.plugin_gem 'cronedit',    :version => '~> 0.3.0'
  config.plugin_gem 'addressable', :version => '~> 2.1.0', :lib => 'addressable/uri' 
  config.plugin_gem 'nokogiri',    :version => '~> 1.3.0'
end
