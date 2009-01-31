module TestServer
  class Rails
    def initialize
      puts "Loading Rails environment"
      ENV["RAILS_ENV"] = "test"
      
      # Some handstands to force dependencies to use :load as a load mechanism
      # no matter what the environment says.
      require File.expand_path("config/boot")
      require 'initializer'
      ::Rails::Initializer.send :define_method, :initialize_dependency_mechanism do
        ActiveSupport::Dependencies.mechanism = :load
      end
      
      require File.expand_path("config/environment")
    end

    def reload_application
      ActionController::Routing::Routes.reload
      ActionController::Base.view_paths.reload!
      ActionView::Helpers::AssetTagHelper::AssetTag::Cache.clear

      Dir["#{RAILS_ROOT}/config/initializers/**/*.rb"].sort.each do |initializer|
        load(initializer)
      end

      require 'dispatcher' unless defined?(::Dispatcher)
      Dispatcher.define_dispatcher_callbacks(true)
      Dispatcher.new(::Rails.logger).send :run_callbacks, :prepare_dispatch
    end
  
    def cleanup_application
      ActiveRecord::Base.reset_subclasses if defined?(ActiveRecord)
      ActiveSupport::Dependencies.clear
      ActiveRecord::Base.clear_reloadable_connections! if defined?(ActiveRecord)
      reset_database!
      reset_fixtures!
    end

    def reset_database!
      if in_memory_database?
        load "#{RAILS_ROOT}/db/schema.rb" # use db agnostic schema by default
        ActiveRecord::Migrator.up('db/migrate') # use migrations
      end
    end
      
    def reset_fixtures!
      if Object.const_defined?(:Fixtures) && Fixtures.respond_to?(:reset_cache)
        Fixtures.reset_cache
      end
    end
      
    def in_memory_database?
      ENV["RAILS_ENV"] == "test" and
      ::ActiveRecord::Base.connection.class.to_s == "ActiveRecord::ConnectionAdapters::SQLite3Adapter" and
      ::Rails::Configuration.new.database_configuration['test']['database'] == ':memory:'
    end
  end
end