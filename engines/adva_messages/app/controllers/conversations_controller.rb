class ConversationsController < BaseController
  authentication_required
  helper :messages
  before_filter :set_conversation, :only => :show
  
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
    @conversation.mark_messages_as_read
  end
  
  protected
  
    def set_conversation
      @conversation = current_user.conversations.find(params[:id])
    rescue
      flash[:error] = "Requested conversation could not be found"
      write_flash_to_cookie # TODO make around filter or something
      redirect_to messages_path
    end
end