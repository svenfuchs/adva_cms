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
  
  describe "DELETE to destroy" do
    before :each do
      @message = Factory :message, :recipient_id => @user.id
      @message.stub!(:mark_as_deleted)
      Message.stub!(:find).and_return(@message)
    end
    act! { request_to :delete, "/messages/#{@message.id}"}
    it_assigns :message
    it_redirects_to { 'http://test.host/messages' }
    
    it "sets message as deleted for recipient" do
      @message.should_receive(:mark_as_deleted).with(@user)
      act!
    end
  end
end
