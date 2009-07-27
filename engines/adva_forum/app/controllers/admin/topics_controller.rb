class Admin::TopicsController < Admin::BaseController
  helper :forum
  before_filter :set_section
  before_filter :set_topics

  guards_permissions :topic

  def index
  end
  
  protected
  
    def set_menu
      @menu = Menus::Admin::Topics.new
    end

    def set_topics
      @topics = @section.topics.all(:include => :board, :order => 'topics.last_updated_at DESC, topics.id DESC').paginate(:count => 25)
    end
end