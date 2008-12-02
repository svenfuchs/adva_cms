class ConversationsController < BaseController
  authentication_required
  helper :messages

  # Gmail style messages  
  # def index
  #   @conversations = current_user.conversations
  # end
  # 
  # def sent
  #   @conversations = current_user.conversations_sent
  #   
  #   render :template => "conversations/index"
  # end
  
  def show
    @conversation = Conversation.find(params[:id])
  end
end