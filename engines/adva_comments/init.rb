# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

ActiveRecord::Base.send :include, ActiveRecord::HasManyComments
ActionController::Base.send :include, ActionController::ActsAsCommentable

# wtf ...
ActiveSupport::Dependencies.autoloaded_constants -= %w(ActionController::ActsAsCommentable ActiveRecord::HasManyComments)

require 'format'

# add JavaScripts and Stylesheets
# for Rails 2.3
# ActionView::Helpers::AssetTagHelper.javascript_expansions[:adva_cms_admin] += ['adva_cms/admin/comment.js']
# ActionView::Helpers::AssetTagHelper.stylesheet_expansions[:adva_cms_public] += ['adva_cms/comments']

# for Rails 2.2
ActionView::Helpers::AssetTagHelper::JavaScriptSources.expansions[:adva_cms_admin] += ['adva_cms/admin/comment.js']
ActionView::Helpers::AssetTagHelper::StylesheetSources.expansions[:adva_cms_public] += ['adva_cms/comments']