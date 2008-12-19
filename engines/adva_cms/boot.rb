# require "#{RAILS_ROOT}/vendor/adva/plugins/cells/boot"
require "#{RAILS_ROOT}/vendor/adva/plugins/engines/boot"

# TODO make this a cattr_accessor on Engines::Plugin?
Engines::Plugin.class_eval do
  def default_code_paths
    %w(app/controllers app/helpers app/models app/observers components lib)
  end
end

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

Rails::Configuration.class_eval do
  def default_plugins
    [ :engines_config, :theme_support, :better_nested_set, :safemode, :adva_cms, :all ]
  end

  def default_plugin_paths
    paths = ["#{root_path}/vendor/adva/engines", "#{root_path}/vendor/adva/plugins", "#{root_path}/vendor/plugins"]
    paths << "#{root_path}/vendor/adva/spec" if ENV['RAILS_ENV'] == 'test'
    paths
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
require 'haml'
