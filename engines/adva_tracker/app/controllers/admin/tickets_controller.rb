class Admin::TicketsController < Admin::BaseController
  def new
    @ticket = Ticket.new
  end
  
  def create
    @ticket = Ticket.new(params[:ticket])

    if @ticket.save
      flash[:notice] = t(:"adva.tracker.flash.ticket_successfully_created")
      redirect_to admin_ticket_path(@site, @section, @ticket)
    else
      flash.now[:notice] = t(:"adva.tracker.flash.ticket_creation_failed")
      render :action => "new"
    end
  end
end
