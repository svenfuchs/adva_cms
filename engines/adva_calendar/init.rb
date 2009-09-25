Mime::Type.register "text/calendar", :ics

I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**/*.{rb,yml}')]

config.to_prepare do
  Section.register_type 'Calendar'
end

register_stylesheet_expansion :admin => %w( adva_calendar/admin/calendar )
register_stylesheet_expansion :admin_alternate => %w( adva_calendar/admin/calendar )
