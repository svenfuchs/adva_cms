# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

ActiveRecord::Base.send :include, ActiveRecord::HasManyComments
ActionController::Base.send :include, ActionController::ActsAsCommentable

# wtf ...
ActiveSupport::Dependencies.autoloaded_constants -= %w(ActionController::ActsAsCommentable ActiveRecord::HasManyComments)

require 'format'

# register javascripts and stylesheets
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :adva_cms_admin  => ['adva_cms/admin/comment.js']
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :adva_cms_public => ['adva_cms/comments']
