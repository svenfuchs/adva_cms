# remove plugin from load_once_paths 
Dependencies.load_once_paths -= Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

ActiveRecord::Base.send :include, ActiveRecord::ActsAsCommentable
ActionController::Base.send :include, ActionController::ActsAsCommentable

# wtf ...
Dependencies.autoloaded_constants -= %w(ActionController::ActsAsCommentable ActiveRecord::ActsAsCommentable)

require 'format'