require File.dirname(__FILE__) + '/../spec_helper'

describe ConversationsController do
  include SpecControllerHelper
  
  before :each do
    @user         = Factory :user
    controller.stub!(:current_user).and_return(@user)
    set_resource_paths :conversation, '/conversations/'
  end
  
  # describe "GET to index" do
  #   act! { request_to :get, '/conversations' }
  #   it_assigns :conversations
  #   
  #   it "fetches the conversations" do
  #     @user.should_receive(:conversations)
  #     act!
  #   end
  # end
  # 
  # describe "GET to sent" do
  #   act! { request_to :get, '/conversations/sent' }
  #   it_assigns :conversations
  #   it_renders_template 'index'
  #   
  #   it "fetches only the conversations user started" do
  #     @user.should_receive(:conversations_sent)
  #     act!
  #   end
  # end
  
  describe "GET to show" do
    before :each do
      @conversation = Conversation.create
    end
    
    describe "with valid conversation" do
      before :each do
        @user.conversations.stub!(:find).and_return(@conversation)
      end
      act! { request_to :get, "/conversations/#{@conversation.id}" }
      it_assigns :conversation
    
      it "marks all the messages as read" do
        @conversation.should_receive(:mark_messages_as_read)
        act!
      end
    end
    
    describe "with invalid conversation" do
      before :each do
        @user.conversations.stub!(:find).and_raise ActiveRecord::RecordNotFound
      end
      act! { request_to :get, "/conversations/#{@conversation.id}" }
      it_assigns_flash_cookie :error => :not_nil
      it_redirects_to {'/messages'}
    end
  end
end