require File.expand_path(File.dirname(__FILE__) + "/../test_helper.rb")

class ConversationsControllerTest < ActionController::TestCase
  tests ConversationsController
  
  with_common :a_site, :log_in_as_user_with_message
  
  def default_params
    { :id => @message.conversation_id }
  end
  
  def invalid_params
    { :id => 'not valid id' }
  end
  
  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end
  
  describe "GET to show" do
    before do
      @conversation = @message.conversation
    end
    
    action { get :show, default_params }
    
    it_assigns :conversation
    it_renders_template 'conversations/show'
    
    it "marks conversation as read" do
      @conversation.messages.each do |message|
        assert message.read_at != nil
      end
    end
    
    # FIXME add view assertions for important things
  end
  
  describe "GET to show, with invalid params" do
    before do
      @conversation = @message.conversation
    end
    
    action { get :show, invalid_params }
    
    it_redirects_to 'messages'
    it_assigns_flash_cookie :error => :not_nil
    it_assigns :conversation => :undefined
    
    it "does not mark conversation as read" do
      @conversation.messages.each do |message|
        assert message.read_at == nil
      end
    end
  end
end