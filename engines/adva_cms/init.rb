# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

require 'redcloth'

require 'time_hacks'
require 'core_ext/hash'
require 'core_ext/kernel'
require 'core_ext/module'
require 'core_ext/string'
require 'rails_ext/active_record/sti_instantiation'
require 'rails_ext/active_record/sticky_changes'
require 'rails_ext/action_controller/event_helper'

require 'routing'
require 'lambda_table'
require 'roles'


# turn this on to get detailed cache sweeper logging in production mode
# Site.cache_sweeper_logging = true

TagList.delimiter = ' '
Tag.destroy_unused = true
Tag.class_eval do def to_param; name end end

XssTerminate.untaint_after_find = true

# patch acts_as_versioned to play nice with xss_terminate
require 'action_controller/dispatcher'
ActionController::Dispatcher.to_prepare do
  ActiveRecord::Base.class_eval do
    class << self
      unless method_defined?(:acts_as_versioned_without_filters_attributes)
        alias :acts_as_versioned_without_filters_attributes :acts_as_versioned
        def acts_as_versioned(*args)
          acts_as_versioned_without_filters_attributes(*args)
          versioned_class.filters_attributes :none => true
        end
      end
    end
  end 
end

Engines.public_directory = "public"
Engines::Assets.class_eval do
    @@warning = %{Files in this directory are automatically generated from your plugins.
They are copied from the 'assets' directories of each plugin into this directory
each time Rails starts (script/server, script/console... and so on).
Any edits you make will NOT persist across the next server restart; instead you
should edit the files within the <plugin_name>/assets/ directory itself.}

  class << self
    def initialize_base_public_directory
      # nothing to do
    end

    def mirror_files_for(plugin)
      return if plugin.public_directory.nil?
      begin
        %w(images javascripts stylesheets).each do |subdir|
          source = File.join(plugin.public_directory, subdir).gsub(RAILS_ROOT + '/', '')
          destination = File.join(Engines.public_directory, subdir, plugin.name)
          Engines.mirror_files_from(source, destination)
          if File.exist?(destination)
            warning = File.join(destination, "WARNING")
            File.open(warning, 'w') { |f| f.puts @@warning } unless File.exist?(warning)
          end
        end
      rescue Exception => e
        Engines.logger.warn "WARNING: Couldn't create the public file structure for plugin '#{plugin.name}'; Error follows:"
        Engines.logger.warn e
      end
    end
  end
end
