# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }
I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']

# register javascripts and stylesheets
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :adva_cms_admin  => ['adva_cms/admin/asset.js', 'adva_cms/admin/asset_widget.js']
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :adva_cms_public => ['adva_cms/assets']
