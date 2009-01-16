class TopicsController < BaseController
  authenticates_anonymous_user

  helper :forum
  before_filter :set_topic, :only => [:show, :edit, :update, :destroy, :previous, :next]
  before_filter :set_posts, :only => :show
  before_filter :set_board, :only => [:new, :update]
  cache_sweeper :topic_sweeper, :only => [:create, :update, :destroy]
  caches_page_with_references :show, :track => ['@topic', '@posts']

  guards_permissions :topic, :except => [:show, :index], :show => [:previous, :next]
  before_filter :guard_topic_permissions, :only => [:create, :update]

  def index
  end

  def show
    @post = Post.new(:author => current_user)
  end

  def new
    @topic = Topic.new :section => @section, :board => @board
  end

  def create
    @topic = @section.topics.post(current_user, params[:topic])
    
    if @topic.save
      trigger_events @topic
      flash[:notice] = t(:'adva.topics.flash.create.success')
      redirect_to topic_path(@section, @topic.permalink)
    else
      flash[:error] = t(:'adva.topics.flash.create.failure')
      render :action => :new
    end
  end

  def edit
  end

  def update
    @topic.revise current_user, params[:topic]
    if @topic.save
      trigger_events @topic
      flash[:notice] = t(:'adva.topics.flash.update.success')
      redirect_to topic_path(@section, @topic.permalink)
    else
      flash[:error] = t(:'adva.topics.flash.update.failure')
      render :action => "edit"
    end
  end

  def destroy
    if @topic.destroy
      trigger_events @topic
      flash[:notice] = t(:'adva.topics.flash.destroy.success')
      redirect_to params[:return_to] || forum_path(@section)
    else
      flash[:error] = t(:'adva.topics.flash.destroy.failure')
      set_posts
      render :action => :show
    end
  end

  def previous
    topic = @topic.previous || @topic
    flash[:notice] = t(:'adva.topics.flash.no_previous_topic') if topic == @topic
    redirect_to topic_path(@section, topic.permalink)
  end

  def next
    topic = @topic.next || @topic
    flash[:notice] = t(:'adva.topics.flash.no_next_topic') if topic == @topic
    redirect_to topic_path(@section, topic.permalink)
  end

  protected

    def set_section; super(Forum); end

    def set_board
      # Board_id depends on if this this GET to a new action or PUT to update
      # NOTE: GET from backend comes without board_id
      board_id = params[:board_id]          if request.get?
      board_id = params[:topic][:board_id]  if request.put?
      # We only need to fetch board if there actually is board_id supplied.
      if @section.boards.any? && board_id
        @board = @section.boards.find board_id
        raise "Could not set board while posting to #{@section.path.inspect}" if @board.blank?
      end
    end

    def set_topic
      @topic = @section.topics.find_by_permalink params[:id]
      redirect_to forum_path(@section) unless @topic # this happens after the last comment has been deleted
    end

    def set_posts
      @posts = @topic.comments.paginate :page => current_page, :per_page => @section.comments_per_page
    end

    def guard_topic_permissions
      unless has_permission? :moderate, :topic
        params[:topic].reject!{|key, value| ['sticky', 'locked'].include? key } if params[:topic]
      end
    end

    def current_role_context
      @topic || @section
    end
end
