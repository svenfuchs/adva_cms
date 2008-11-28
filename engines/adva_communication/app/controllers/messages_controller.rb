class MessagesController < BaseController
  authentication_required
  before_filter :set_message, :only => [:show, :destroy]
  
  def index
    @message_box  = 'Inbox'
    @messages     = current_user.messages_received
  end
  
  def sent
    @message_box  = 'Outbox'
    @messages     = current_user.messages_sent
    
    render :template => "messages/index"
  end
  
  def show
    @message.mark_as_read
  end
  
  def new
    @message = Message.new
  end
  
  def create
    @message = current_user.messages_sent.build(params[:message])
    
    if @message.save
      trigger_events @message
      redirect_to messages_path
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @message.mark_as_deleted(current_user)
    
    redirect_to messages_path
  end
  
  protected
    def set_message
      @message = Message.find(params[:id])
    end
end