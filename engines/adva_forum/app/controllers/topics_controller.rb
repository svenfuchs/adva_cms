class TopicsController < BaseController
  authenticates_anonymous_user

  helper :forum
  before_filter :set_section
  before_filter :set_topic, :only => [:show, :edit, :update, :destroy, :previous, :next]
  before_filter :set_posts, :only => :show
  before_filter :set_board, :only => [:new, :update]
  cache_sweeper :topic_sweeper, :only => [:create, :update, :destroy]
  caches_page_with_references :show, :track => ['@topic', '@posts', {'@topic' => :posts_count}]

  guards_permissions :topic, :except => [:show, :index], :show => [:previous, :next]
  before_filter :guard_topic_permissions, :only => [:create, :update]

  # FIXME do we even use index action?
  def index
  end

  def show
    @post = Post.new(:author => current_user)
  end

  def new
    @topic = Topic.new(:section => @section, :board => @board)
  end

  def create
    @topic = @section.topics.post(current_user, params[:topic])
    unless @topic.new_record?
      trigger_events(@topic)
      flash[:notice] = t(:'adva.topics.flash.create.success')
      redirect_to topic_url(@section, @topic.permalink)
    else
      flash[:error] = t(:'adva.topics.flash.create.failure')
      render :action => :new
    end
  end

  def edit
  end

  def update
    if @topic.update_attributes(params[:topic])
      trigger_events(@topic)
      flash[:notice] = t(:'adva.topics.flash.update.success')
      redirect_to topic_url(@section, @topic.permalink)
    else
      flash[:error] = t(:'adva.topics.flash.update.failure')
      render :action => "edit"
    end
  end

  def destroy
    if @topic.destroy # TODO uhm? what is the scenario where this actually fails?
      trigger_events(@topic)
      flash[:notice] = t(:'adva.topics.flash.destroy.success')
      redirect_to params[:return_to] || forum_url(@section)
    else
      flash[:error] = t(:'adva.topics.flash.destroy.failure')
      set_posts
      render :action => :show
    end
  end

  # TODO: can't we handle this in the frontend? seems like overkill to me ...
  def previous
    topic = @topic.previous || @topic
    flash[:notice] = t(:'adva.topics.flash.no_previous_topic') if topic == @topic
    redirect_to topic_url(@section, topic.permalink)
  end

  def next
    topic = @topic.next || @topic
    flash[:notice] = t(:'adva.topics.flash.no_next_topic') if topic == @topic
    redirect_to topic_url(@section, topic.permalink)
  end

  protected

    def set_section; super(Forum); end

    def set_board
      # board_id depends on if this is a GET to a new action or a PUT to update
      # NOTE: GET from backend comes without a board_id
      board_id = params[:board_id]         if request.get?
      board_id = params[:topic][:board_id] if request.put?
      # We only need to fetch a board if there actually is a board_id supplied.
      if @section.boards.any? && board_id
        @board = @section.boards.find(board_id)
        raise "Could not set board on #{@section.path.inspect}" if @board.blank?
      end
    end

    def set_topic
      # FIXME simplify this ...
      @topic = @section.topics.find(:first, :conditions => ["id = ? OR permalink = ?", params[:id], params[:id]])
      redirect_to forum_url(@section) unless @topic # this happens after the last post has been deleted
    end

    def set_posts
      @posts = @topic.posts.paginate(:page => current_page, :per_page => @section.posts_per_page)
    end

    def guard_topic_permissions
      unless has_permission? :moderate, :topic
        params[:topic].reject! { |key, value| ['sticky', 'locked'].include?(key) } if params[:topic]
      end
    end

    def current_resource
      @topic || @section
    end
end
