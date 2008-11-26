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
end