require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class AnonymousCannotAccessConversationsTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_a_section
    factory_scenario :conversation_with_messages
  end
  def test_the_anonymous_user_visits_the_conversation
    # go to inbox
    get conversation_path(@conversation)
    
    # the page renders the login screen
    assert_redirected_to login_path(:return_to => "http://www.example.com/conversations/#{@conversation.id}")
  end
end

class UserBrowsesConversationsTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_a_section
    login_as :user
    factory_scenario :conversation_with_messages
  end

  def test_the_user_reads_the_conversation
    # messages are unread
    @conversation.messages.each do |message|
      assert message.read_at == nil
    end
    
    # go to message
    get conversation_path(@conversation)
    
    # the page renders the show view
    assert_template 'conversations/show'
    
    # messages are read
    @conversation.reload
    @conversation.messages.each do |message|
      assert message.read_at != nil
    end
  end
end
