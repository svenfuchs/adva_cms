class MessagesController < BaseController
  authentication_required
  
  def index
    @messages = current_user.messages_received
  end
  
  def outbox
    @messages = current_user.messages_sent
  end
  
  def new
    
  end
  
  def destroy
    @message = Message.find(params[:id])
    @message.mark_as_deleted(current_user)
    
    redirect_to messages_path
  end
end