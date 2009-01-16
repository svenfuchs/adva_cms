class PostsController < BaseController
  authenticates_anonymous_user

  before_filter :set_section
  before_filter :set_topic
  before_filter :set_post, :only => [:edit, :update, :destroy]
  cache_sweeper :comment_sweeper, :only => [:create, :update, :destroy]

  def new
    @post = Post.new
  end

  def create
    @post = @topic.reply current_user, params[:post]
    if @post.save
      flash[:notice] = t(:'adva.posts.flash.create.success')
      redirect_to topic_path(@section, @topic.permalink, :anchor => dom_id(@post)) # TODO include page
    else
      flash[:error] = t(:'adva.posts.flash.create.failure')
      render :action => "new"
    end
  end

  def edit
  end

  def update
    if @post.update_attributes(params[:post])
      flash[:notice] = t(:'adva.posts.flash.update.success')
      redirect_to topic_path(@section, @topic.permalink, :anchor => dom_id(@post)) # TODO include page
    else
      flash[:error] = t(:'adva.posts.flash.update.failure')
      render :action => "edit"
    end
  end

  def destroy
    if @post == @topic.initial_post
      flash[:error] = "Initial topic post cannot be deleted"
      redirect_to params[:return_to] || topic_path(@section, @topic)
    else
      @post.destroy
      flash[:notice] = t(:'adva.posts.flash.destroy.success')
      redirect_to params[:return_to] || topic_path(@section, @topic)
    end
  end

  protected
    def set_section; super(Forum); end

    def set_topic
      @topic = @section.topics.find params[:topic_id]
    end

    def set_post
      @post = @topic.comments.find params[:id]
    end

    def current_role_context
      @post || @topic
    end
end
