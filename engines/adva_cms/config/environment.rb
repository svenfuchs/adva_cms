Rails::Initializer.configure do |config|
  config.reload_plugins = true
  
  config.plugins = [ :simple_nested_set, :safemode, :adva_cms, :all ]

  config.plugin_gem 'json',      :version => '~> 1.1.2', :lib => 'json'
  config.plugin_gem 'BlueCloth', :version => '~> 1.0.0', :lib => 'bluecloth'
  config.plugin_gem 'RedCloth',  :version => '~> 3.0.4', :lib => 'redcloth'
  config.plugin_gem 'rubypants', :version => '~> 0.2.0', :lib => 'rubypants'

  # the implementation of plugin_gem immediately loads the gem. paperclip
  # requires activerecord to be loaded. thus we only add the loadpath and 
  # actually load it during adva_cms/init.rb.
  #
  # also, this gem is required by adva_assets, adva_photos and adva_themes. it
  # doesn't seem to make too much sense to ship it with each of these engines
  # at this point. so we just leave it here.
  $: << File.dirname(__FILE__) + '/../vendor/gems/thoughtbot-paperclip-2.2.2/lib'
  # require 'paperclip'
  # config.plugin_gem 'thoughtbot-paperclip', :version => '~> 2.2.2', :lib => 'paperclip'
end
