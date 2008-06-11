class TopicsController < BaseController
  helper :forum
  before_filter :set_topic, :only => [:show, :edit, :update, :destroy, :previous, :next]
  before_filter :set_posts, :only => :show
  caches_page_with_references :show, :track => ['@topic', '@posts']

  def show
    @comment = Post.new
  end

  def new
    @topic = Topic.new
  end

  def create 
    @topic = @section.topics.post current_user, params[:topic] # sticky, locked if permissions
    if @topic.save
      flash[:notice] = 'The topic has been created.'
      redirect_to topic_path(@section, @topic.permalink)
    else
      flash[:error] = 'The topic could not be created.'
      render :action => :new
    end
  end

  def update    
    if @topic.revise current_user, params[:topic] 
      flash[:notice] = 'The topic has been updated.'
      redirect_to topic_path(@section, @topic.permalink)
    else
      flash[:error] = 'The topic could not be updated.'
      render :action => "edit"
    end
  end

  def destroy
    if @topic.destroy
      flash[:notice] = 'The topic has been deleted.'
      redirect_to forum_path(@section)
    else
      flash[:error] = 'The topic could not be deleted.'
      set_posts
      render :action => :show
    end
  end
  
  def previous
    topic = @topic.previous || @topic
    flash[:notice] = 'There is no previous topic. Showing the last one.' if topic == @topic
    redirect_to topic_path(@section, topic.permalink)
  end
  
  def next
    topic = @topic.next || @topic
    flash[:notice] = 'There is no next topic. Showing the last one.' if topic == @topic
    redirect_to topic_path(@section, topic.permalink)
  end

  protected
  
    def set_section
      super Forum
    end

    def set_topic
      @topic = @section.topics.find_by_permalink(params[:id])
      redirect_to forum_path(@section) unless @topic # this happens after the last comment has been deleted
    end

    def set_posts
      @posts = @topic.comments.paginate :page => current_page, 
                                        :per_page => @section.articles_per_page # TODO
    end
    
    def current_role_context
      @topic || @section
    end
end
