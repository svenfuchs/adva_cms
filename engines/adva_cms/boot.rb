# require "#{RAILS_ROOT}/vendor/adva/plugins/engines/boot"
require "#{RAILS_ROOT}/vendor/adva/plugins/cells/boot"

# initialize Rails::Configuration with our own default values to spare users
# some hassle with the installation and keep the environment cleaner
#
# we need to do this because Rails does not allow to define multiple config
# initializer blocks, extend the existing one or change it in any way.
#
# might be more "elegant" to wrap around Rails::Initializer.run and extend
# the configuration object
#
# TODO how to improve this?

module Rails
  mattr_reader :plugins
  @@plugins = ActiveSupport::OrderedHash.new
end

Rails::Configuration.class_eval do
  def default_load_paths
    %w(app/controllers app/helpers app/models app/observers lib)
  end
  
  def default_plugin_loader
    Rails::Plugin::PublishingLoader
  end
  
  def default_plugins
    [ :better_nested_set, :safemode, :adva_cms, :all ]
  end

  def default_plugin_paths
    paths = ["#{root_path}/vendor/adva/engines", "#{root_path}/vendor/adva/plugins", "#{root_path}/vendor/plugins"]
    paths << "#{root_path}/vendor/adva/test" if ENV['RAILS_ENV'] == 'test'
    paths
  end
end

Rails::Plugin.class_eval do
  class PublishingLoader < Rails::Plugin::Loader # ummm, what's a better name?
    def register_plugin_as_loaded(plugin)
      Rails.plugins[plugin.name.to_sym] = plugin
      super
    end
  end
  
  def app_paths
    ['models', 'helpers', 'observers'].map { |path| File.join(directory, 'app', path) } << controller_path
  end
  
  def register_javascript_expansion(*args)
    ActionView::Helpers::AssetTagHelper.register_javascript_expansion *args
  end
  
  def register_stylesheet_expansion(*args)
    ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion *args
  end
end

# Rails::GemDependency does not allow to freeze gems anywhere else than vendor/gems
# So we hook up our own directories ...
#
# TODO how to improve this?

gem_dir = "#{RAILS_ROOT}/vendor/adva/gems"
Dir[gem_dir + '/*'].each{|dir| $:.unshift dir + '/lib'}

require 'bluecloth'
require 'redcloth'
require 'ruby_pants'
require 'zip/zip'
require 'cronedit'
require 'activerecord' # paperclip needs activerecord to be present
require 'paperclip'
