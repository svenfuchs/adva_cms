require File.dirname(__FILE__) + '/../spec_helper'

describe "Message views:" do
  include SpecViewHelper
  
  before :each do
    template.stub!(:render).with hash_including(:partial => 'messages')
    template.stub!(:render).with hash_including(:partial => 'message-nav')
  end
  
  describe "index" do
    act! { render "messages/index" }
    
    it "renders message navigation partial" do
      template.should_receive(:render).with hash_including(:partial => 'message_nav')
      act!
    end
    
    it "renders messages partial" do
      template.should_receive(:render).with hash_including(:partial => 'messages')
      act!
    end
    
    it "has a header that tells you that you are on inbox" do
      act!
      response.should have_tag('h2')
    end
  end
  
  describe "outbox" do
    act! { render "messages/index" }
    
    it "renders message navigation partial" do
      template.should_receive(:render).with hash_including(:partial => 'message_nav')
      act!
    end
    
    it "renders messages partial" do
      template.should_receive(:render).with hash_including(:partial => 'messages')
      act!
    end
    
    it "has a header that tells you that you are on outbox" do
      act!
      response.should have_tag('h2')
    end
  end
  
  describe "show" do
    before :each do
      @message = Factory :message
    end
    act! { render "messages/show" }
    
    it "renders message navigation partial" do
      template.should_receive(:render).with hash_including(:partial => 'message_nav')
      act!
    end
  end
  
  describe "new" do
    before :each do
      Site.delete_all
      assigns[:site] = Factory :site
      template.stub!(:recipients_list).and_return([['John Wayne', '666']])
    end
    act! { render "messages/new" }
    
    it "renders message navigation partial" do
      template.should_receive(:render).with hash_including(:partial => 'message_nav')
      act!
    end
    
    it "should render the message form label for recipient" do
      act!
      response.should have_tag('label[for=?]', 'message_recipient')
    end
    
    it "should render the message form field for recipient" do
      act!
      response.should have_tag('select[name=?]', 'message[recipient_id]')
    end
    
    it "should render the message form label for subject" do
      act!
      response.should have_tag('label[for=?]', 'message_subject')
    end
    
    it "should render the message form field for subject" do
      act!
      response.should have_tag('input[name=?]', 'message[subject]')
    end
    
    it "should render the message form label for body" do
      act!
      response.should have_tag('label[for=?]', 'message_body')
    end
    
    it "should render the message form field for body" do
      act!
      response.should have_tag('textarea[name=?]', 'message[body]')
    end
    
    it "should render the message form button for sending the message" do
      act!
      response.should have_tag('input[name=?]', 'commit')
    end
    
    it "should render the cancel link" do
      act!
      response.should have_tag('a[href=?]', '/messages')
    end
  end
  
  describe "_message_nav" do
    act! { render "messages/_message_nav"}
    
    it "has a link to composing a new mail" do
      act!
      response.should have_tag('a[href=?]', '/messages/new')
    end
    
    it "has a link to inbox" do
      act!
      response.should have_tag('a[href=?]', '/messages')
    end
    
    it "has a link to outbox" do
      act!
      response.should have_tag('a[href=?]', '/messages/sent')
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
      
    it "has a link to mark message as unread"
  end
end