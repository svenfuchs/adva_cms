# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

config.to_prepare do
  Section.register_type 'Forum'
end

# add Stylesheets
# for Rails 2.3
# ActionView::Helpers::AssetTagHelper.stylesheet_expansions[:adva_cms_public] += ['adva_cms/forum']

# for Rails 2.2
ActionView::Helpers::AssetTagHelper::StylesheetSources.expansions[:adva_cms_public] += ['adva_cms/forum']