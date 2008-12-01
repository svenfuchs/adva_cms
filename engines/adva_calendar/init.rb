# remove plugin from load_once_paths 
Mime::Type.register "text/calendar", :ics

ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

ActiveSupport::Dependencies.load_once_paths += %W(#{ File.dirname(__FILE__) }app/models/calendar/)


config.to_prepare do
  Section.register_type 'Calendar'
  require 'calendar/event'
end