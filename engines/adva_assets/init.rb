# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }
I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']

# register javascripts and stylesheets
register_javascript_expansion :admin => %w( adva_assets/admin/asset.js adva_cms/admin/asset_widget.js )
register_stylesheet_expansion :admin => %w( adva_assets/admin/assets )
