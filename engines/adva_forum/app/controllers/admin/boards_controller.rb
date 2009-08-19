class Admin::BoardsController < Admin::BaseController
  helper :forum
  before_filter :set_section
  before_filter :set_boards, :only => [:index]
  before_filter :set_board,  :only => [:edit, :update, :destroy]

  cache_sweeper :board_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :board

  def index
  end

  def new
    @board = @section.boards.build
  end

  def create
    @board = @section.boards.build(params[:board])
    if @board.save
      flash[:notice] = t(:'adva.boards.flash.create.success')
      redirect_to admin_boards_url
    else
      flash.now[:error] = t(:'adva.boards.flash.create.failure')
      render :action => "new"
    end
  end

  def edit
  end

  def update
    if @board.update_attributes(params[:board])
      flash[:notice] = t(:'adva.boards.flash.update.success')
      redirect_to admin_boards_url
    else
      flash.now[:error] = t(:'adva.boards.flash.update.failure')
      render :action => 'edit'
    end
  end

  def update_all
    @section.boards.update(params[:boards].keys, params[:boards].values)
    render :text => 'OK'
  end

  def destroy
    if @board.destroy # FIXME remove if else, or is there really a scenario for it?
      flash[:notice] = t(:'adva.boards.flash.destroy.success')
      redirect_to admin_boards_url
    else
      flash.now[:error] = t(:'adva.boards.flash.destroy.failure')
      render :action => 'edit'
    end
  end

  protected

    def set_menu
      @menu = Menus::Admin::Boards.new
    end

    def set_boards
      @boards = @section.boards(:order => :position)
    end

    def set_board
      @board = @section.boards.find(params[:id])
    end
end
