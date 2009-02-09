# remove plugin from load_once_paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

Mime::Type.register "text/calendar", :ics

I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']

config.to_prepare do
  Section.register_type 'Calendar'
end

# register javascripts and stylesheets
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :adva_cms_admin  => ['adva_calendar/admin/calendar.js']
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :adva_cms_public => ['adva_calendar/calendar.js']