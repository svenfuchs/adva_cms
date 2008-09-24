# remove plugin from load_once_paths 
Dependencies.load_once_paths -= Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

# hook activities into site
module Activities
  def self.included(base)
    base.has_many :activities, :dependent => :destroy
  end
end

Activities.include_into 'Site'

ActiveRecord::Base.observers += %w(activities/article_observer activities/comment_observer activities/wikipage_observer)
