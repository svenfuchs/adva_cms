Mime::Type.register "text/calendar", :ics

I18n.load_path += Dir[File.dirname(__FILE__) + '/config/locales/**/*.yml']

config.to_prepare do
  Section.register_type 'Calendar'
end

register_javascript_expansion :admin   => %w( adva_calendar/admin/calendar.js )
