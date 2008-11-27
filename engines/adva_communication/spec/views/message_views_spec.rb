require File.dirname(__FILE__) + '/../spec_helper'

describe "Message views:" do
  include SpecViewHelper
  
  describe "index" do
    before :each do
      template.stub!(:render).with hash_including(:partial => 'messages')
    end
    act! { render "messages/index" }
    
    it "renders messages partial" do
      template.should_receive(:render).with hash_including(:partial => 'messages')
      act!
    end
    
    it "has a header that tells you that you are on inbox" do
      act!
      response.should have_tag('h2', /Inbox/)
    end
  end
  
  describe "outbox" do
    before :each do
      template.stub!(:render).with hash_including(:partial => 'messages')
    end
    act! { render "messages/outbox" }
    
    it "renders messages partial" do
      template.should_receive(:render).with hash_including(:partial => 'messages')
      act!
    end
    
    it "has a header that tells you that you are on outbox" do
      act!
      response.should have_tag('h2', /Outbox/)
    end
  end
  
  describe "_messages" do
    describe "when messages is set" do
      before :each do
        @message = Factory :message
        template.stub!(:messages).and_return [@message]
        template.stub!(:render).with hash_including(:partial => 'message')
      end
      act! { render "messages/_messages"}
    
      it "has a link to composing a new mail" do
        act!
        response.should have_tag('a', /Compose a mail/)
      end
    
      it "has a list of messages" do
        act!
        response.should have_tag('div#messages')
      end
    
      it "renders message partial" do
        template.should_receive(:render).with hash_including(:partial => 'message')
        act!
      end
    end
    
    describe "when messages is not set" do
      before :each do
        template.stub!(:messages).and_return []
      end
      act! { render "messages/_messages"}
      
      it "has a list of messages" do
        act!
        response.should have_tag('div#messages')
      end
      
      it "has empty paragraph that tells that there are no messages" do
        act!
        response.should have_tag('p.empty', /You do not have any messages./)
      end
    end
  end
  
  describe "_message" do
    before :each do
      @message = Factory :message
      template.stub!(:message).and_return @message
    end
    act! { render "messages/_message"}
    
    it "has the message" do
      act!
      response.should have_tag("div#message_#{@message.id}")
    end
    
    it "has the content of the message" do
      act!
      response.should have_tag("div.content")
    end
    
    it "has the link to show the message" do
      act!
      response.should have_tag("a", "#{@message.subject}")
    end
    
    it "has the link to delete the message" do
      act!
      response.should have_tag("a", /delete/)
    end
  end
end