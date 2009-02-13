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
  #   render :action => "index"
  # end
  
  def show
    @conversation.mark_messages_as_read
  end
  
  protected
  
    def set_conversation
      conversation = Conversation.find(params[:id])
      # FIXME i think #my_conversations is way too expensive
      #       but it is currently only way to show conversation
      #       that was sent by the user but what was not replied on
      if current_user.my_conversations.include?(conversation)
        @conversation = conversation
      else
        raise ActiveRecord::RecordNotFound
      end
    rescue
      flash[:error] = "Requested conversation could not be found"
      write_flash_to_cookie # TODO make around filter or something
      redirect_to messages_path
    end
end