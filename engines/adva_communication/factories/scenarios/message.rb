Factory.define_scenario :user_with_messages do
  raise "@user not set" unless @user
  @message_sent     ||= Factory.create :message, :sender_id => @user.id
  @message_received ||= Factory.create :message, :recipient_id => @user.id
end