class TopicsController < BaseController
  helper :forums
  before_filter :set_topic, :only => [:show, :edit, :update, :destroy, :previous, :next]
  before_filter :set_posts, :only => :show

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
      flash[:notice] = 'Topic was successfully updated.'
      redirect_to topic_path(@section, @topic.permalink)
    else
      render :action => "edit"
    end
  end

  def destroy
    @topic.destroy
    redirect_to forum_path(@section)
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
    end

    def set_posts
      @posts = @topic.posts.paginate :page => current_page, 
                                     :per_page => @section.articles_per_page # TODO
    end
end
