require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class ConversationsTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with sections'
    @user = User.find_by_email('a-user@example.com')
    @conversation = @user.conversations.first
  end
  
  test 'an anonymous user visits the conversation' do
    visit_the_conversation
    redirect_to_login
  end

  test 'the user reads the conversation' do
    login_as_user
    visit_the_conversation
    read_the_conversation
  end
  
  
  def visit_the_conversation
    get conversation_path(@conversation)
  end
  
  def redirect_to_login
    assert_redirected_to login_path(:return_to => "http://site-with-sections.com/conversations/#{@conversation.id}")
  end
  
  def read_the_conversation
    assert_template 'conversations/show'
    
    @conversation.reload
    @conversation.messages.each do |message|
      assert message.read_at != nil
    end
  end
end
