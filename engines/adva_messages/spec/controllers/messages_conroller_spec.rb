require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do
  include SpecControllerHelper
  
  before :each do
    @user     = Factory :johan_mcdoe
    @message  = Factory :message
    
    controller.stub!(:current_user).and_return @user
    @user.stub!(:messages).and_return [@message]
    @user.messages_received.stub!(:paginate).and_return @message
    @user.messages_sent.stub!(:paginate).and_return @message
    Message.stub!(:find).and_return @message
    
    set_resource_paths :message, '/messages/'
  end
  
  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end
  
  describe "GET to index" do
    act! { request_to :get, '/messages' }
    it_assigns :message_box
    it_assigns :messages
    
    it "fetches only the received messages" do
      @user.should_receive(:messages_received).and_return([])
      act!
    end
  end
  
  describe "GET to sent" do
    act! { request_to :get, '/messages/sent' }
    it_assigns :message_box
    it_assigns :messages
    it_renders_template 'index'
    
    it "fetches only the sent messages" do
      @user.should_receive(:messages_sent).and_return([])
      act!
    end
  end
  
  describe "GET to show" do
    act! { request_to :get, "/messages/#{@message.id}" }
    it_assigns :message
    
    it "marks message as read" do
      @message.should_receive(:mark_as_read)
      act!
    end
  end
  
  describe "GET to new" do
    before :each do
      @message = Message.new
      Message.stub!(:new).and_return @message
    end
    act! { request_to :get, '/messages/new' }
    it_assigns :message
  end
  
  describe "GET to reply" do
    before :each do
      Message.stub!(:reply_to).and_return @message
    end
    act! { request_to :get, "/messages/#{@message.id}/reply" }
    it_assigns :message
    
    it "assigns a new message" do
      Message.should_receive(:reply_to).with(@message)
      act!
    end
  end
  
  describe "POST to create" do
    before :each do
      @recipient  = Factory :don_macaroni
      @params     = { :recipient => @recipient,
                      :subject   => 'subject',
                      :body      => 'body' }
      @message    = Message.new(@params.merge(:sender => @user))
      @user.messages_sent.stub!(:build).and_return(@message)
    end
    act! { request_to :post, '/messages', @params }
    
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
        @message.stub!(:save).and_return false
      end
      it_renders_template :new
      it_does_not_trigger_any_event
    end
    
    describe "when replying with invalid parameters" do
      before :each do
        @message = Factory :reply
        @user.messages_sent.stub!(:build).and_return(@message)
        @message.stub!(:save).and_return false
      end
      it_renders_template :reply
      it_does_not_trigger_any_event
    end
  end
  
  describe "DELETE to destroy" do
    before :each do
      @message.stub!(:mark_as_deleted)
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
