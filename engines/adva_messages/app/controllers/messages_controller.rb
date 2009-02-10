class MessagesController < BaseController
  authentication_required
  renders_with_error_proc :below_field
  before_filter :set_message, :only => [:show, :reply, :destroy]
  
  def index
    @message_box  = 'Inbox'
    @messages     = current_user.messages_received.paginate message_paginate_options
  end
  
  def sent
    @message_box  = 'Outbox'
    @messages     = current_user.messages_sent.paginate message_paginate_options
    
    render :action => "index"
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
      flash[:notice] = "Message was sent successfully."
      trigger_events @message
      redirect_to messages_path
    else
      flash[:error] = "Sending of message failed."
      @message.is_reply? ? render(:action => 'reply') : render(:action => 'new')
    end
  end
  
  def destroy
    @message.mark_as_deleted(current_user)
    flash[:notice] = "Message was successfully deleted."
    redirect_to messages_path
  end
  
  protected
    def set_message
      @message = Message.find(params[:id])
      unless current_user.messages.include?(@message)
        @message = nil
        flash[:error] = "Requested messages could not be found"
        write_flash_to_cookie # TODO make around filter or something
        redirect_to messages_path
      end
    end
    
    def message_paginate_options
      {:page => params[:page], :order => 'created_at DESC'}
    end
end