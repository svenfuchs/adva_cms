class PostsController < BaseController
  before_filter :set_topic
  before_filter :set_post, :only => [:edit, :update, :destroy]

  def new
    @post = Post.new
  end

  def create
    @post = @topic.reply current_user, params[:post]
    if @post.save
      flash[:notice] = 'The post has been saved.'
      redirect_to topic_path(@section, @topic.permalink, :anchor => dom_id(@post)) # TODO include page
    else
      flash[:error] = 'The post could not be saved.'
      render :action => "new"
    end
  end

  def update
    if @post.update_attributes(params[:post])
      flash[:notice] = 'The post has been updated.'
      redirect_to topic_path(@section, @topic.permalink, :anchor => dom_id(@post)) # TODO include page
    else
      flash[:error] = 'The post could not be updated.'
      render :action => "edit"
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = 'The post has been deleted.'
    redirect_to params[:redirect_to] || topic_path(@section, @topic)
  end

  protected
    def set_section
      super Forum
    end
  
    def set_topic
      @topic = @section.topics.find params[:topic_id]
    end
  
    def set_post
      @post = @topic.comments.find params[:id]
    end
end
