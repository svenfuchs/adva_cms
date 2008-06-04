# remove plugin from load_once_paths 
Dependencies.load_once_paths -= Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

require 'redcloth'
# require 'tzinfo' # now in Rails 2.1?

require 'time_hacks'
require 'core_ext/string'
require 'core_ext/kernel'
require 'rails_ext/active_record/dom_id'
require 'rails_ext/active_record/sti_instantiation'

# turn this on to get detailed cache sweeper logging in production mode
# Site.cache_sweeper_logging = true

TagList.delimiter = ' '
Tag.destroy_unused = true
Tag.class_eval do def to_param; name end end

