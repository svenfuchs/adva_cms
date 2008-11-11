# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

require 'redcloth'

require 'time_hacks'
require 'core_ext/hash'
require 'core_ext/kernel'
require 'core_ext/module'
require 'core_ext/object_try'
require 'core_ext/string'
require 'rails_ext/active_record/sti_instantiation'
require 'rails_ext/active_record/sticky_changes'
require 'rails_ext/action_controller/event_helper'

require 'routing'
require 'roles'
require 'event' # need to force event to be loaded now, so it won't be reloaded between requests

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



