class TopicsController < BaseController
  authenticates_anonymous_user
  
  helper :forum
  before_filter :set_topic, :only => [:show, :edit, :update, :destroy, :previous, :next]
  before_filter :set_posts, :only => :show
  before_filter :set_board, :only => [:new, :update]
  caches_page_with_references :show, :track => ['@topic', '@posts']
  
  guards_permissions :topic, :show => [:previous, :next]
  
  def index
  end
  
  def show
    @post = Post.new :author => current_user
  end

  def new
    @topic = Topic.new :section => @section, :board => @board, :author => current_user
  end

  def create 
    @topic = @section.topics.post current_user, params[:topic] # TODO check sticky, locked against permissions
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
    flash[:notice] = 'There is no previous topic. Showing the first one.' if topic == @topic
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
    
    def set_board
      @board = @section.boards.find params[:board_id] if params[:board_id]
      raise "Could not set board while posting to #{@section.path.inspect}" if @section.boards.any? && @board.blank?
    end

    def set_topic
      @topic = @section.topics.find_by_permalink params[:id]
      redirect_to forum_path(@section) unless @topic # this happens after the last comment has been deleted
    end

    def set_posts
      @posts = @topic.comments.paginate :page => current_page, :per_page => @section.comments_per_page
    end
    
    def current_role_context
      @topic || @section
    end
end
