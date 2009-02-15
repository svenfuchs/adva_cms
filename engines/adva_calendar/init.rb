# remove plugin from load_once_paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

Mime::Type.register "text/calendar", :ics

I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']

config.to_prepare do
  Section.register_type 'Calendar'
end

register_javascript_expansion :admin   => %w( adva_calendar/admin/calendar.js )
