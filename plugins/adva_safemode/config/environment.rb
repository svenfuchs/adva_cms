Rails::Initializer.configure do |config|
  config.plugin_gem 'sexp_processor', :version => '> 3.0.3', :lib => 'sexp_processor'
  config.plugin_gem 'ruby_parser',    :version => '> 2.0.4', :lib => 'ruby_parser'
  config.plugin_gem 'ruby2ruby',      :version => '> 1.2.4', :lib => 'ruby2ruby'
end

