# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{ |path| path =~ %r(^#{File.dirname(__FILE__)}) }

# include FCKeditor
# for Rails 2.3
# ActionView::Helpers::AssetTagHelper.javascript_expansions[:adva_cms_admin] += ['fckeditor/fckeditor/fckeditor.js', 'fckeditor/setup_fckeditor.js']

# for Rails 2.2
# ActionView::Helpers::AssetTagHelper::JavaScriptSources.expansions[:adva_cms_admin] += ['fckeditor/fckeditor/fckeditor.js', 'fckeditor/setup_fckeditor.js']