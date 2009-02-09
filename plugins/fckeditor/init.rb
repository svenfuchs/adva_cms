# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{ |path| path =~ %r(^#{File.dirname(__FILE__)}) }

# register javascripts and stylesheets
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :adva_cms_admin  => ['fckeditor/fckeditor/fckeditor.js', 'adva_fckeditor/setup_fckeditor.js']
