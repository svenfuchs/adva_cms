# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

config.to_prepare do
  Section.register_type 'Forum'
end

# register javascripts and stylesheets
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :adva_cms_public => ['adva_cms/forum']
