require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class PeepingTomTest < ActionController::IntegrationTest
  def setup
    @site             = Factory :site
    login_as          :user
    factory_scenario  :conversation_with_messages
    @site.users << @peeping_tom  = @user
    @site.users << @johan_mcdoe  = @conversation.messages.first.sender
    @site.users << @don_macaroni = @conversation.messages.first.recipient
    @first_message = @johan_mcdoe.conversations.first.messages.first
  end
  
  def test_cannot_read_my_conversations
    # Check that there is one conversation
    @johan_mcdoe.conversations.count == 1
    
    # Peeping tom tries to see the conversation that he is not part of
    get conversation_path(@johan_mcdoe.conversations.first)
    
    # Instead of seeing the conversation, peeping tom is redirected to his own inbox
    assert_redirected_to '/messages'
    
    # and my messages are not read
    @johan_mcdoe.conversations.first.messages.each do |message|
      assert message.read_at == nil
    end
  end
  
  def test_cannot_view_my_messages
    # Check that there is one conversation
    @johan_mcdoe.conversations.count == 1
    
    # Peeping tom tries to see the conversation that he is not part of
    get message_path(@first_message)
    
    # Instead of seeing the conversation, peeping tom is redirected to his own inbox
    assert_redirected_to '/messages'
    
    # and my message is not read
    assert @first_message.read_at == nil
  end
  
  def test_cannot_answer_to_my_messages
    # Check that there is one conversation
    @johan_mcdoe.conversations.count == 1
    
    # Peeping tom tries to go to reply to message he is not part of
    get reply_message_path(@first_message)
    
    # Instead of seeing the reply form, peeping tom is redirected to his own inbox
    assert_redirected_to '/messages'
    
    # and my message is not read
    assert @first_message.read_at == nil
  end
  
  def test_cannot_delete_my_messages
    # Check that there is one conversation
    @johan_mcdoe.conversations.count == 1
    
    # Peeping tom tries to see the conversation that he is not part of
    delete message_path(@first_message)
    
    # Instead of seeing the conversation, peeping tom is redirected to his own inbox
    assert_redirected_to '/messages'
    
    # and my message is not deleted
    assert @first_message.deleted_at_recipient == nil
    assert @first_message.deleted_at_sender    == nil
  end
end