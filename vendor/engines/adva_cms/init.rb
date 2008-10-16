# remove plugin from load_once_paths 
Dependencies.load_once_paths -= Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

require 'redcloth'

require 'time_hacks'
require 'core_ext/hash'
require 'core_ext/kernel'
require 'core_ext/module'
require 'core_ext/string'
require 'rails_ext/active_record/sti_instantiation'
require 'rails_ext/active_record/original_state'
require 'rails_ext/action_controller/event_helper'

require 'routing'

# turn this on to get detailed cache sweeper logging in production mode
# Site.cache_sweeper_logging = true

TagList.delimiter = ' '
Tag.destroy_unused = true
Tag.class_eval do def to_param; name end end