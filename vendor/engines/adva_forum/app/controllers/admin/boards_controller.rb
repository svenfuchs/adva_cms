class Admin::BoardsController < Admin::BaseController
  before_filter :set_section
  before_filter :set_boards, :only => [:index]
  before_filter :set_board,  :only => [:edit, :update, :destroy]

  # cache_sweeper :board_sweeper, :only => [:create, :update, :destroy]
  # guards_permissions :board

  def index
  end

  def new
    @board = @section.boards.build
  end

  def create
    @board = @section.boards.build params[:board]
    if @board.save
      flash[:notice] = "The board has been created."
      redirect_to admin_boards_path
    else
      flash.now[:error] = "The board could not be created."
      render :action => "new"
    end
  end

  def edit
  end

  def update
    if @board.update_attributes params[:board]
      flash[:notice] = "The board has been updated."
      redirect_to admin_boards_path
    else
      flash.now[:error] = "The board could not be updated."
      render :action => 'edit'
    end
  end

  def update_all
    @section.boards.update(params[:boards].keys, params[:boards].values)
    render :text => 'OK'
  end

  def destroy
    if @board.destroy
      flash[:notice] = "The board has been deleted."
      redirect_to admin_boards_path
    else
      flash.now[:error] = "The board could not be deleted."
      render :action => 'edit'
    end
  end

  protected

    def set_section; super; end

    def set_boards
      @boards = @section.boards :order => :position
    end

    def set_board
      @board = @section.boards.find(params[:id])
    end
end
