# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

ActiveRecord::Base.send :include, ActiveRecord::HasManyComments
ActionController::Base.send :include, ActionController::ActsAsCommentable

# wtf ...
ActiveSupport::Dependencies.autoloaded_constants -= %w(ActionController::ActsAsCommentable ActiveRecord::HasManyComments)

require 'format'

# register javascripts and stylesheets
register_javascript_expansion :admin   => %w( adva_comments/admin/comments.js )
register_stylesheet_expansion :default => %w( adva_comments/comments )
