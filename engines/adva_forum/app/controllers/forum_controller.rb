class ForumController < BaseController
  before_filter :set_section
  before_filter :set_board, :only => :show
  before_filter :set_boards, :only => :show
  before_filter :set_topics, :only => :show

  caches_page_with_references :show, :comments, :track => [
    '@topics', '@boards', '@board', '@topic',
    {'@section' => :topics_count}, {'@section' => :posts_count},
    {'@boards' => :topics_count}, {'@boards' => :posts_count},
    {'@board' => :topics_count}, {'@board' => :posts_count},
    {'@topics' => :posts_count }
  ]

  authenticates_anonymous_user
  acts_as_commentable # TODO hu?

  def show
    # beast does this:
    # (session[:forums] ||= {})[@forum.id] = Time.now.utc
    # (session[:forums_page] ||= Hash.new(1))[@forum.id] = current_page if current_page > 1

    # we only need this topic for the topic/new form, right? if so, can we move
    # this to the form partial instead of using an instance variable?
    @topic = Topic.new(:section => @section, :board => @board, :author => current_user)
  end

  protected

    def set_section; super(Forum); end

    # FIXME these filters are confusing. maybe have some more explicit methods
    # here like displaying_boards? or displaying_boardless_topics? or whatever
    # else makes sense ...

    def set_board
      @board = @section.boards.find params[:board_id] if params[:board_id]
    end

    def set_boards
      @boards = @section.boards unless @board
    end

    def set_topics
      if @board or @boards.blank?
        collection = @board ? @board.topics : @section.topics
        @topics = collection.paginate :page => current_page,
                                      :per_page => @section.topics_per_page,
                                      :include => :last_post
      end
    end
end
