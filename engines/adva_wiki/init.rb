# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

config.to_prepare do
  Section.register_type 'Wiki'
end

# add JavaScripts
# for Rails 2.3
# ActionView::Helpers::AssetTagHelper.javascript_expansions[:adva_cms_admin] += ['adva_cms/admin/wikipage.js']

# for Rails 2.2
ActionView::Helpers::AssetTagHelper::JavaScriptSources.expansions[:adva_cms_admin] += ['adva_cms/admin/wikipage.js']