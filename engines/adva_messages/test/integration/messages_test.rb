require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class MessagesTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with sections'
    @user = User.find_by_email('a-user@example.com')
    @moderator = User.find_by_first_name('a moderator')
    @message_received = @user.messages_received.first
    @message_sent     = @user.messages_sent.first
    @reply_to = @moderator.messages_sent.first
    @conversation = @user.conversations.first
  end
  
  test 'the anonymous user visits the inbox' do
    visit_inbox
    redirect_to_login
  end
  
  test 'the user visits the inbox' do
    login_as_user
    visit_inbox
    display_inbox
  end
  
  test 'the user visits the outbox' do
    login_as_user
    visit_outbox
    display_outbox
  end

  test 'the user visits message new form from outbox' do
    login_as_user
    visit_outbox
    click_link 'New message'
    display_new_form
  end
  
  test 'the user deletes a message from inbox' do
    login_as_user
    visit_inbox
    delete_the_received_message
  end

  test 'the user deletes a message from outbox' do
    login_as_user
    visit_outbox
    delete_the_sent_message
  end
    
  test 'the user sends a message' do
    login_as_user
    visit_inbox
    click_link 'New message'
    display_new_form
    fill_in_and_submit_the_new_form
  end
  
  test 'the user replies to a message' do
    login_as_user
    visit_inbox
    click_reply_link
    display_reply_form
    fill_in_and_submit_the_reply_form
  end

  # TODO not implemented feature
  #
  # test 'the user marks a message as unread' do
  #   login_as_user
  #   visit_inbox
  #   # user has received message
  #   assert @user.messages_received.count == 1
  #   @message = @user.messages_received.first
  #   
  #   assert @message.read_at != nil
  #   
  #   click_link 'mark as unread'
  #   
  #   assert @message.read_at == nil
  # end
  
  def visit_inbox
    get '/messages'
  end
  
  def visit_outbox
    get '/messages/sent'
  end
  
  def redirect_to_login
    assert_redirected_to login_path(:return_to => "http://site-with-sections.com/messages")
  end
  
  def display_inbox
    assert_template 'messages/index'
    has_tag "h2", :text => /Inbox/
  end
  
  def display_outbox
    assert_template 'messages/index'
    has_tag "h2", :text => /Outbox/
  end
  
  def display_new_form
    assert_template 'messages/new'
  end
  
  def delete_the_received_message
    click_link "message_#{@message_received.id}_delete"
    
    @message_received.reload
    assert @message_received.deleted_at_recipient != nil
  end
  
  def delete_the_sent_message
    click_link "message_#{@message_sent.id}_delete"
    
    @message_sent.reload
    assert @message_sent.deleted_at_sender != nil
  end
  
  def fill_in_and_submit_the_new_form
    messages_count = @user.messages_sent.count
    moderator_messages_count = @moderator.messages_received.count
    
    select       @moderator.name, :from => 'message[recipient_id]'
    fill_in      'subject',      :with => 'the message subject'
    fill_in      'body',         :with => 'the message body'
    click_button 'Save'
    
    @user.reload
    assert @user.messages_sent.count == messages_count + 1
    @moderator.reload
    assert @moderator.messages_received.count == moderator_messages_count + 1
  end
  
  def display_reply_form
    assert_template 'messages/reply'
  end
  
  def fill_in_and_submit_the_reply_form
    messages_count = @user.messages_sent.count
    moderator_messages_count = @moderator.messages_received.count
    
    fill_in      'body',        :with => 'the reply body'
    click_button 'Save'
    
    @user.reload
    assert @user.messages_sent.count == messages_count + 1
    @moderator.reload
    assert @moderator.messages_received.count == moderator_messages_count + 1
  end
  
  def click_reply_link
    click_link "message_#{@reply_to.id}_reply"
  end
end