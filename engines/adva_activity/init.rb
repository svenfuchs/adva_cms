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

# add Stylesheets
# for Rails 2.3
# ActionView::Helpers::AssetTagHelper.stylesheet_expansions[:adva_cms_admin] += 'adva_cms/admin/activities'

# for Rails 2.2
ActionView::Helpers::AssetTagHelper::StylesheetSources.expansions[:adva_cms_admin] += ['adva_cms/admin/activities']