# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '~> 2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

# TODO make this a cattr_accessor on Engines::Plugin?
Engines::Plugin.class_eval { def default_code_paths; %w(app/controllers app/helpers app/models app/observers components lib) end }

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with rake gem:install on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'BlueCloth', :lib => "bluecloth"
  config.gem 'RedCloth',  :lib => "redcloth"
  config.gem 'rubypants', :lib => 'ruby_pants'
  config.gem 'rubyzip',   :lib => 'zip/zip'
  config.gem 'haml',      :lib => 'haml'  
  config.gem 'json'
  # config.gem 'rspec',     :lib => 'spec'
  # config.gem 'rspec-rails', :lib => 'spec'

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  config.plugins = [ :engines_config, :theme_support, :better_nested_set, :safemode, :adva_cms, :all ]

  config.plugin_paths << "#{RAILS_ROOT}/vendor/engines"
  config.plugin_paths << "#{RAILS_ROOT}/vendor/spec" if ENV['RAILS_ENV'] == 'test'

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make ActiveRecord store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run `rake -D time` for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_adva_cms_session',
    :secret      => '6e7072d70edd618b59dc2b6a7ffa24c6c33e19806899895f46c72b99a1298de75f0688a26a672e17a1d90e48c7db36084d712ae294b6eb5e0d0030a549937e34'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
end
