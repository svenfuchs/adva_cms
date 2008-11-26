require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do
  include SpecControllerHelper
  
  before :each do
    @user = Factory :user
    controller.stub!(:current_user).and_return(@user)
    set_resource_paths :message, '/messages/'
  end
  
  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end
  
  describe "GET to index" do
    act! { request_to :get, '/messages' }
    it_assigns :messages
    
    it "fetches only the received messages" do
      @user.should_receive(:messages_received)
      act!
    end
  end
  
  describe "GET to outbox" do
    act! { request_to :get, '/messages/outbox' }
    it_assigns :messages
    
    it "fetches only the sent messages" do
      @user.should_receive(:messages_sent)
      act!
    end
  end
end
