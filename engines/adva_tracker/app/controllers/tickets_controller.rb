class TicketsController < BaseController
  authenticates_anonymous_user
  helper :tracker
  
  def index
    @parent = Project.find(params[:project_id], :include => :tickets) #TODO make it more decoupled
    @tickets = @parent.tickets
  end

  def show
    @ticket = Ticket.find(params[:id])
  end

  def new
    @ticket = Ticket.new(:section => @section)
  end
  
  def edit
    @ticket = Ticket.find(params[:id])
  end
  
  def create
    @ticket = Ticket.new(params[:ticket].merge(:author => current_user))

    if @ticket.save
      flash[:notice] = t(:"adva.tracker.flash.ticket_successfully_created")
      redirect_to tickets_path(@section, @ticket.ticketable_id)
    else
      flash.now[:error] = t(:"adva.tracker.flash.ticket_creation_failed")
      render :action => "new"
    end
  end
  
  def update
    @ticket = Ticket.find(params[:id])
    
    if @ticket.update_attributes(params[:ticket].merge(:author => current_user))
      flash[:notice] = t(:"adva.tracker.flash.ticket_successfully_updated")
      redirect_to tickets_path(@section, @ticket.ticketable_id)
    else
      flash.now[:error] = t(:"adva.tracker.flash.ticket_creation_failed")
      render :action => "new"
    end
  end
  
  def destroy
    @ticket = Ticket.find(params[:id])
    @ticket.destroy
    flash[:notice] = t(:"adva.tracker.flash.ticket_successfully_deleted")
    redirect_to tickets_path(@section, @ticket.ticketable_id)
  end
end
