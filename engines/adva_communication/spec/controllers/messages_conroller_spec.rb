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
    it_assigns :site
    
    it "fetches only the received messages" do
      @user.should_receive(:messages_received)
      act!
    end
  end
  
  describe "GET to outbox" do
    act! { request_to :get, '/messages/outbox' }
    it_assigns :messages
    it_assigns :site
    
    it "fetches only the sent messages" do
      @user.should_receive(:messages_sent)
      act!
    end
  end
  
  describe "GET to new" do
    act! { request_to :get, '/messages/new' }
    it_assigns :message
    it_assigns :site
  end
  
  describe "POST to create" do
    before :each do
      @recipient  = Factory :don_macaroni
      @params     = { :recipient_id => @recipient.id,
                      :subject      => 'subject',
                      :body         => 'body' }
      @message    = Message.new(@params.merge(:sender_id => @user.id))
      @user.messages_sent.stub!(:build).and_return(@message)
    end
    act! { request_to :post, '/messages', @params }
    it_assigns :site
    
    it "builds a new sent message for user" do
      @user.messages_sent.should_receive(:build).and_return(@message)
      act!
    end
    
    describe "with valid parameters" do
      it_redirects_to { 'http://test.host/messages' }
      it_triggers_event :message_created
      
      it "saves the message" do
        @message.should_receive(:save).and_return true
        act!
      end
    end
    
    describe "with invalid parameters" do
      before :each do
        @message.should_receive(:save).and_return false
      end
      it_renders_template :new
      it_does_not_trigger_any_event
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
    it_assigns :site
    it_redirects_to { 'http://test.host/messages' }
    
    it "sets message as deleted for recipient" do
      @message.should_receive(:mark_as_deleted).with(@user)
      act!
    end
  end
end
