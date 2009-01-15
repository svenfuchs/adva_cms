class ForumController < BaseController
  before_filter :set_board, :only => :show
  before_filter :set_boards, :only => :show
  before_filter :set_topics, :only => :show
  caches_page_with_references :show, :track => ['@topics', '@boards', '@board']

  authenticates_anonymous_user
  acts_as_commentable # TODO hu?

  def show
    # beast does this:
    # (session[:forums] ||= {})[@forum.id] = Time.now.utc
    # (session[:forums_page] ||= Hash.new(1))[@forum.id] = current_page if current_page > 1
    @topic = Topic.new(:section => @section, :board => @board, :author => current_user)
    render @section.render_options
  end

  protected

    def set_section; super(Forum); end
    
    def set_board
      @board = @section.boards.find params[:board_id] if params[:board_id]
    end
    
    def set_boards
      @boards = @section.boards
    end

    def set_topics
      collection = @board ? @board.topics : @section.topics
      @topics = collection.paginate :page => current_page,
                                    :per_page => @section.topics_per_page,
                                    :include => :last_comment
    end
end
