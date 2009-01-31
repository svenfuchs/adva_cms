require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class AnonymousCannotAccessMessagesTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_a_section
  end
  
  def test_the_anonymous_user_visits_the_inbox
    # go to inbox
    get '/messages'
    
    # the page renders the login screen
    assert_redirected_to login_path(:return_to => 'http://www.example.com/messages')
  end
end

class UserBrowsesMessageFoldersTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_a_section
    login_as :user
    factory_scenario :conversation_with_messages
  end
  
  def test_the_user_visits_the_inbox
    # go to inbox
    get '/messages'
    
    # the page renders the inbox
    assert_template 'messages/index'
  end
  
  def test_the_user_visits_the_outbox
    # go to outbox
    get '/messages/sent'
    
    # the page renders the outbox
    assert_template 'messages/index'
  end
  
  def test_the_user_visits_message_new_form_from_inbox
    # go to inbox
    get '/messages'
    
    # clicks a link to create a new message
    click_link 'New message'
    
    # the page renders the new form
    assert_template 'messages/new'
  end

  def test_the_user_visits_message_new_form_from_outbox
    # go to inbox
    get '/messages/sent'
    
    # clicks a link to create a new message
    click_link 'New message'
    
    # the page renders the new form
    assert_template 'messages/new'
  end
end

class UserManipulatesMessages < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_a_section
    login_as :user
    factory_scenario :user_with_conversation
  end
  
  def test_the_user_deletes_a_message_from_inbox
    # go to inbox
    get '/messages'
    
    # user has received message
    assert @user.messages_received.count == 1
    
    click_link 'delete'
    
    assert @user.messages_received.count == 0
  end

  def test_the_user_deletes_a_message_from_outbox
    # go to outbox
    get '/messages/sent'
    
    # user has sent message
    assert @user.messages_sent.count == 1
    
    click_link 'delete'
    
    assert @user.messages_sent.count == 0
  end
    
  def test_the_user_sends_a_message
    johan_mcdoe = Factory :johan_mcdoe
    
    @site.users << johan_mcdoe
    @site.users << @user
    
    # site has two users
    assert @site.users.count == 2
    
    # go to message create form
    get '/messages/new'
    
    # user has sent a message before
    assert @user.messages_sent.count == 1
    
    # johan does not have any received messages yet
    assert johan_mcdoe.messages_received.count == 0
    
    # user fills the message form
    select       'Johan McDoe', :from => 'message[recipient_id]'
    fill_in      'subject',     :with => 'the message subject'
    fill_in      'body',        :with => 'the message body'
    click_button 'Save'
    
    # user has sent one more message
    assert @user.messages_sent.count == 2
    
    # and johan received one message
    assert johan_mcdoe.messages_received.count == 1
  end
  
  def test_the_user_replies_to_a_message
    johan_mcdoe = Factory :johan_mcdoe
    
    @site.users << johan_mcdoe
    @site.users << @user
    
    # user has one sent mail before
    assert @user.messages_sent.count == 1
    
    # johan mcdoe has no received mail before
    johan_mcdoe.messages_received.count == 0
    
    # go to inbox
    get '/messages'
    
    # user has received one message from johan mcdoe
    @message_received.update_attribute(:sender, johan_mcdoe)
    
    click_link 'reply'
    
    # the page renders the reply view
    assert_template 'messages/reply'
    
    # user fills the message form
    fill_in      'body',        :with => 'the reply body'
    click_button 'Save'
    
    # the page renders the reply view
    assert_template 'messages/index'
    
    # user has sent one more message
    assert @user.messages_sent.count == 2
    
    # johan mcdoe has received the reply
    johan_mcdoe.messages_received.count == 1
  end
  
  # def test_the_user_marks_a_message_as_unread
  #   # go to inbox
  #   get '/messages'
  #   
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
end