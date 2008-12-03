Factory.define_scenario :user_with_conversation do
  raise "@user not set" unless @user
  don_macaroni  = Factory :don_macaroni
  @conversation = Factory :conversation
  @conversation.messages.build Factory.attributes_for(:message, :sender => @user,  :recipient => don_macaroni)
  @conversation.messages.build Factory.attributes_for(:reply,   :sender => don_macaroni, :recipient => @user)
  @conversation.messages.each {|m| m.save!}
  @message_sent     = @conversation.messages.first
  @message_received = @conversation.messages.last
  @conversation     = @user.conversations.first  # hrmh
end