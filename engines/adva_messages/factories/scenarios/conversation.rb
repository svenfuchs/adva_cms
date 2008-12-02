Factory.define_scenario :conversation_with_messages do
  @conversation                 = Factory :conversation
  @conversation.messages.create Factory.attributes_for(:message)
  @conversation.messages.create Factory.attributes_for(:reply)
end