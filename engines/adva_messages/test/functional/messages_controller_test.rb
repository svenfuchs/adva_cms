require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class MessagesControllerTest < ActionController::TestCase
  tests MessagesController
  
  with_common :a_site, :log_in_as_user_with_message, :superusers_message
  
  def default_params
    { :id => @message.id }
  end
  
  def another_users_params
    { :id => @superuser_message.id }
  end
  
  def valid_message_params
    { :message => { :subject      => 'a new message',
                    :body         => 'a new message body',
                    :recipient_id => @message.recipient_id,
                    :sender_id    => @message.sender_id } }
  end
  
  def invalid_message_params
    invalid_message_params = valid_message_params
    invalid_message_params[:message][:recipient_id] = nil
    invalid_message_params
  end
  
  def it_has_message_form(form_action)
    raise "Form_action must be set set!" if form_action.nil?
    has_form_posting_to messages_path do
      has_tag :select,    :id => 'message_recipient_id' unless form_action == :reply
      has_tag :input,     :id => 'message_subject'
      has_tag :textarea,  :id => 'message_body'
      has_tag :input,     :id => 'message_submit'
      has_tag :a,         :href => '/messages'
    end
  end
  
  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end
  
  describe "GET to index" do
    action { get :index }
    
    it_assigns :message_box
    it_assigns :messages
    it_renders_template 'messages'
    
    # FIXME add view assertions for important things
  end
  
  describe "GET to sent" do
    action { get :index }
    
    it_assigns :message_box
    it_assigns :messages
    it_renders_template 'messages'
    
    # FIXME add view assertions for important things
  end
  
  describe "GET to show" do
    action { get :show, default_params }
    
    it_assigns :message
    it_renders_template 'messages/show'
    
    it "marks the message as read" do
      @message.reload
      assert @message.read_at != nil
    end
    
    # FIXME add view assertions for important things
  end
  
  describe "GET to show, disallows viewing another users message" do
    action { get :show, another_users_params }
    
    it_redirects_to 'messages'
    it_assigns_flash_cookie :error => :not_nil
    
    it "sets the message to nil" do
      assert_nil assigns(@message)
    end
    
    it "does not mark the message as read" do
      @superuser_message.reload
      assert @superuser_message.read_at == nil
    end
  end
  
  describe "GET to new" do
    action { get :new }
    
    it_assigns :message => Message
    it_renders_template 'messages/new'
    it_has_message_form :create
    
    # FIXME add view assertions for important things
  end
  
  describe "GET to reply" do
    action { get :reply, default_params }
    
    it_assigns :message => Message
    it_renders_template 'messages/reply'
    it_has_message_form :reply
    
    # FIXME add view assertions for important things
  end
  
  describe "GET to reply, disallows answering to another users message" do
    action { get :reply, another_users_params }
    
    it_redirects_to 'messages'
    it_assigns_flash_cookie :error => :not_nil
    
    it "sets the message to nil" do
      assert_nil assigns(@message)
    end
  end
  
  describe "POST to create" do
    action { post :create, valid_message_params }
    
    it_assigns :message => Message
    it_assigns_flash_cookie :notice => :not_nil
    it_triggers_event :message_created
    it_redirects_to 'messages'
  end
  
  describe "POST to create, with invalid params" do
    action { post :create, invalid_message_params }
    
    it_assigns :message => Message
    it_assigns_flash_cookie :error => :not_nil
    it_does_not_trigger_any_event
    it_renders_template 'messages/new'
  end
  
  describe "POST to create, with invalid params from reply" do
    action { post :create, invalid_message_params.merge(:message => { :parent_id => @message.id }) }
    
    it_assigns :message => Message
    it_assigns_flash_cookie :error => :not_nil
    it_does_not_trigger_any_event
    it_renders_template 'messages/reply'
  end
  
  describe "DELETE to destroy" do
    action { delete :destroy, default_params }
    
    it_redirects_to 'messages'
    it_assigns_flash_cookie :notice => :not_nil
    
    it "marks the message as deleted for sender" do
      @message.reload
      assert @message.deleted_at_sender != nil
    end
    
    it "does not mark the message as deleted for recipient" do
      @message.reload
      assert @message.deleted_at_recipient == nil
    end
  end
  
  describe "DELETE to destroy, disallows deletion of another users message" do
    action { delete :destroy, another_users_params }
    
    it_redirects_to 'messages'
    it_assigns_flash_cookie :error => :not_nil
    
    it "sets the message to nil" do
      assert_nil assigns(@message)
    end
    
    it "does not mark the message as deleted for sender" do
      @message.reload
      assert @message.deleted_at_sender == nil
    end
    
    it "does not mark the message as deleted for recipient" do
      @message.reload
      assert @message.deleted_at_recipient == nil
    end
  end
end