class PostsController < BaseController
  authenticates_anonymous_user

  before_filter :set_section
  before_filter :set_topic
  before_filter :set_post, :only => [:edit, :update, :destroy]
  cache_sweeper :post_sweeper, :only => [:create, :update, :destroy]

  guards_permissions :post

  def new
    @post = Post.new(:author => current_user)
  end

  def create
    @post = @topic.reply current_user, params[:post]
    if @post.save
      flash[:notice] = t(:'adva.posts.flash.create.success')
      redirect_to topic_url(@section, @topic.permalink, :anchor => dom_id(@post), :page => @topic.last_page)
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
      redirect_to topic_url(@section, @topic.permalink, :anchor => dom_id(@post), :page => @post.page)
    else
      flash[:error] = t(:'adva.posts.flash.update.failure')
      render :action => "edit"
    end
  end

  def destroy
    if @post == @topic.initial_post
      flash[:error] = "Initial topic post cannot be deleted"
      redirect_to params[:return_to] || topic_url(@section, @topic)
    else
      @post.destroy
      flash[:notice] = t(:'adva.posts.flash.destroy.success')
      params[:return_to].sub!(/page\/[\d]*$/, @post.previous.page.to_s) if params[:return_to]
      redirect_to params[:return_to] || topic_url(@section, @topic, :page => @post.previous.page)
    end
  end

  protected
    def set_section; super(Forum); end

    def set_topic
      @topic = @section.topics.find(params[:topic_id])
    end

    def set_post
      @post = @topic.posts.find(params[:id])
    end

    def current_resource
      @post || @topic
    end
end
