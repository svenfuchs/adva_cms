require File.dirname(__FILE__) + '/../spec_helper'

describe "Message views:" do
  include SpecViewHelper
  
  before :each do
    template.stub!(:render).with hash_including(:partial => 'messages/message_nav')
    template.stub!(:render).with hash_including(:partial => 'messages/inspect')
    template.stub!(:render).with hash_including(:partial => 'messages/form')
  end
  
  describe "show" do
    before :each do
      @conversation                 = Factory :conversation
      @conversation.messages.create Factory.attributes_for(:message)
      @conversation.messages.create Factory.attributes_for(:reply)
      assigns[:conversation]  = @conversation
    end
    act! { render "conversations/show" }
    
    it "renders message navigation partial" do
      template.should_receive(:render).with hash_including(:partial => 'messages/message_nav')
      act!
    end
    
    it "renders message inspect partial for each message" do
      template.should_receive(:render).exactly(2).times.with hash_including(:partial => 'messages/inspect')
      act!
    end
    
    it "has the link to reply to the latest message" do
      act!
      response.should have_tag("a[href=?]", "/messages/#{@conversation.messages.last.id}/reply")
    end
  end
end
