# remove plugin from load_once_paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

Mime::Type.register "text/calendar", :ics

I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']

config.to_prepare do
  Section.register_type 'Calendar'
end

# add JavaScripts
# for Rails 2.3
# ActionView::Helpers::AssetTagHelper.javascript_expansions[:adva_cms_admin] += ['adva_calendar/admin/calendar.js']

# for Rails 2.2
ActionView::Helpers::AssetTagHelper::JavaScriptSources.expansions[:adva_cms_admin] += ['adva_calendar/admin/calendar.js']