# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

config.to_prepare do
  Section.register_type 'Wiki'
end

# register javascripts and stylesheets
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :adva_cms_admin  => ['adva_cms/admin/wikipage.js']