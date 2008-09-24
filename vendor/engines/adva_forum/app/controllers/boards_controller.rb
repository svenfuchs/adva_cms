class BoardsController < BaseController
  helper :forum
  before_filter :set_board, :only => [:show, :edit, :update, :destroy, :previous, :next]
  before_filter :set_topics, :only => :show
  caches_page_with_references :show, :track => ['@board', '@topics']

  guards_permissions :board

  def show
    @comment = Post.new
  end

  def new
    @board = Topic.new
  end

  def create
    @board = @section.boards.topic current_user, params[:board] # sticky, locked if permissions
    if @board.save
      flash[:notice] = 'The board has been created.'
      redirect_to board_path(@section, @board.permalink)
    else
      flash[:error] = 'The board could not be created.'
      render :action => :new
    end
  end

  def update
    if @board.revise current_user, params[:board]
      flash[:notice] = 'The board has been updated.'
      redirect_to board_path(@section, @board.permalink)
    else
      flash[:error] = 'The board could not be updated.'
      render :action => "edit"
    end
  end

  def destroy
    if @board.destroy
      flash[:notice] = 'The board has been deleted.'
      redirect_to forum_path(@section)
    else
      flash[:error] = 'The board could not be deleted.'
      set_topics
      render :action => :show
    end
  end

  def previous
    board = @board.previous || @board
    flash[:notice] = 'There is no previous board. Showing the last one.' if board == @board
    redirect_to board_path(@section, board.permalink)
  end

  def next
    board = @board.next || @board
    flash[:notice] = 'There is no next board. Showing the last one.' if board == @board
    redirect_to board_path(@section, board.permalink)
  end

  protected

    def set_section; super(Forum); end

    def set_board
      @board = @section.boards.find params[:id]
    end

    def set_topics
      @topics = @board.comments.paginate :page => current_page,
                                        :per_page => @section.comments_per_page # TODO
    end

    def current_role_context
      @board || @section
    end
end
