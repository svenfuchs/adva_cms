class MessagesController < BaseController
  authentication_required
  before_filter :set_message,         :only => [:show, :reply, :destroy]
  
  def index
    @message_box  = 'Inbox'
    @messages     = current_user.messages_received.paginate message_paginate_options
  end
  
  def sent
    @message_box  = 'Outbox'
    @messages     = current_user.messages_sent.paginate message_paginate_options
    
    render :template => "messages/index"
  end
  
  def show
    @message.mark_as_read
  end
  
  def new
    @message = Message.new
  end
  
  def reply
    @message = Message.reply_to(@message)
  end
  
  def create
    @message = current_user.messages_sent.build(params[:message])
    
    if @message.save
      trigger_events @message
      redirect_to messages_path
    elsif @message.is_reply?
      render :action => 'reply'
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
    
    def message_paginate_options
      {:page => params[:page], :order => 'created_at DESC'}
    end
end