class MessagesController < BaseController
  authentication_required
  before_filter :set_message,         :only => [:show, :destroy]
  before_filter :set_parent_message , :only => [:reply]
  
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
  
  def reply
    @message = Message.new(:parent_id => params[:id], :subject => @subject)
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
    
    def set_parent_message
      @parent_message = Message.find(params[:id])
      if @parent_message.subject[0..2] == 'Re:'
        @subject = @parent_message.subject
      else
        @subject = 'Re: ' + @parent_message.subject
      end
    end
end