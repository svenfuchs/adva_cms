# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

# hook activities into site
module Activities
  def self.included(base)
    base.has_many :activities, :dependent => :destroy
  end
end

Activities.include_into 'Site'

ActiveRecord::Base.observers += ['activities/activity_observer', 'activities/article_observer',
                                 'activities/comment_observer', 'activities/wikipage_observer',
                                 'activities/topic_observer']

I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']

# register javascripts and stylesheets
register_javascript_expansion :admin => ['adva_cms/admin/asset.js', 'adva_cms/admin/asset_widget.js']
register_stylesheet_expansion :admin => ['adva_cms/admin/activities']
