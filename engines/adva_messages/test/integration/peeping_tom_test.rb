require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class PeepingTomTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with sections'
    @peeping_tom = User.find_by_email('the-peeping-tom@example.com')
    @user = User.find_by_email('a-user@example.com')
    @conversation = @user.conversations.first
    @message = @user.messages.first
  end
  
  test 'the peeping tom cannot read my conversations' do
    login_as_peeping_tom
    view_other_users_conversation
    redirect_to_inbox
    other_users_conversation_is_unread
  end
  
  test 'the peeping tom cannot view my messages' do
    login_as_peeping_tom
    view_other_users_message
    redirect_to_inbox
    other_users_message_is_unread
  end
  
  test 'the peeping tom cannot answer to my messages' do
    login_as_peeping_tom
    reply_to_other_users_message
    redirect_to_inbox
  end
  
  test 'the peeping tom cannot delete my messages' do
    login_as_peeping_tom
    delete_other_users_message
    redirect_to_inbox
    other_users_message_is_not_deleted
  end
  
  def login_as_peeping_tom
    post "/session", :user => {:email => 'the-peeping-tom@example.com', :password => 'a password'}
    assert controller.authenticated?
    controller.current_user
  end
  
  def view_other_users_conversation
    get conversation_path(@conversation)
  end
  
  def view_other_users_message
    get conversation_path(@message)
  end
  
  def redirect_to_inbox
    assert_redirected_to '/messages'
  end
  
  def other_users_conversation_is_unread
    @conversation.messages.each do |message|
      assert message.read_at == nil
    end
  end
  
  def other_users_message_is_unread
    assert @message.read_at == nil
  end
  
  def reply_to_other_users_message
    get reply_message_path(@message)
  end
  
  def delete_other_users_message
    delete message_path(@message)
  end
  
  def other_users_message_is_not_deleted
    assert @message.deleted_at_recipient == nil
    assert @message.deleted_at_sender    == nil
  end
end