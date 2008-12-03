Factory.define_scenario :conversation_with_messages do
  @conversation = Factory :conversation
  johan_mcdoe   = Factory :johan_mcdoe
  don_macaroni  = Factory :don_macaroni
  @conversation.messages.build Factory.attributes_for(:message, :sender => johan_mcdoe,  :recipient => don_macaroni)
  @conversation.messages.build Factory.attributes_for(:reply,   :sender => don_macaroni, :recipient => johan_mcdoe)
  @conversation.messages.each {|m| m.save!}
end