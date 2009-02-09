# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }
I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']

# register javascripts and stylesheets
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :adva_cms_admin  => ['adva_calendar/admin/newsletter.js']
