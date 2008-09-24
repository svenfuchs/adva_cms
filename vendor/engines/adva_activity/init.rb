# remove plugin from load_once_paths 
Dependencies.load_once_paths -= Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

require 'activities/site'

ActiveRecord::Base.observers += %w(activities/article_observer activities/comment_observer activities/wikipage_observer)
