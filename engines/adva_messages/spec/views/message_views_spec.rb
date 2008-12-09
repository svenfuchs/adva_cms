require File.dirname(__FILE__) + '/../spec_helper'

describe "Message views:" do
  include SpecViewHelper
  
  before :each do
    @user = Factory :johan_mcdoe
    template.stub!(:current_user).and_return(@user)
    template.stub!(:render).with hash_including(:partial => 'messages')
    template.stub!(:render).with hash_including(:partial => 'message-nav')
    template.stub!(:render).with hash_including(:partial => 'inspect')
    template.stub!(:render).with hash_including(:partial => 'form')
    template.stub!(:will_paginate)
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
    
    it "paginates the messages" do
      pending 'FIXME'
      template.should_receive(:will_paginate)
      act!
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
    
    it "paginates the messages" do
      pending 'FIXME'
      template.should_receive(:will_paginate)
      act!
    end
  end
  
  describe "show" do
    before :each do
      assigns[:message] = @message = Factory(:message)
    end
    act! { render "messages/show" }
    
    it "renders message navigation partial" do
      template.should_receive(:render).with hash_including(:partial => 'message_nav')
      act!
    end
    
    it "renders message inspect partial" do
      template.should_receive(:render).with hash_including(:partial => 'inspect')
      act!
    end
    
    it "has the link to reply to the message" do
      act!
      response.should have_tag("a[href=?]", "/messages/#{@message.id}/reply")
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
    
    it "renders message form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      act!
    end
  end
  
  describe "reply" do
    before :each do
      Site.delete_all
      assigns[:site]    = Factory :site
      assigns[:message] = Factory :reply
      template.stub!(:recipients_list).and_return([['John Wayne', '666']])
    end
    act! { render "messages/reply" }
    
    it "renders message navigation partial" do
      template.should_receive(:render).with hash_including(:partial => 'message_nav')
      act!
    end
    
    it "renders message form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      act!
    end
    
    it "renders message inspect partial" do
      template.should_receive(:render).with hash_including(:partial => 'inspect')
      act!
    end
    
    it "assigns parent_id for the message" do
      act!
      response.should have_tag('input[name=?]', 'message[parent_id]')
    end
    
    it "assigns recipient_id for the message" do
      act!
      response.should have_tag('input[name=?]', 'message[recipient_id]')
    end
  end
  
  describe "_inspect" do
    before :each do
      @message = Factory :message
      template.stub!(:message).and_return @message
    end
    act! { render "messages/_inspect" }
    
    it "has the message" do
      act!
      response.should have_tag("div#message_#{@message.id}")
    end
    
    it "has message subject in a header" do
      act!
      response.should have_tag('h2', "#{@message.subject}")
    end
    
    it "has message sender name in a paragraph" do
      act!
      response.should have_tag('p#message-sender', /from: #{@message.sender.name}/)
    end
    
    it "has message body in a paragraph" do
      pending 'FIXME'
      act!
      response.should have_tag('div#message-body', /#{@message.body}/)
    end
  end
  
  describe "_form" do
    before :each do
      Site.delete_all
      assigns[:site] = Factory :site
      @message = Factory(:message)
      template.stub!(:message).and_return @message
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:message, @message, template, {}, nil)
    end
    act! { render "messages/_form"}
    
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
      pending 'FIXME'
      act!
      response.should have_tag("div.content")
    end
    
    it "has the link to show the message" do
      act!
      response.should have_tag("a[href=?]", "/conversations/#{@message.conversation.id}#message_#{@message.id}")
    end
    
    it "has the link to delete the message" do
      act!
      response.should have_tag("a", /delete/)
    end
    
    it "has the link to reply to the message" do
      act!
      response.should have_tag("a[href=?]", "/messages/#{@message.id}/reply")
    end
      
    it "has a link to mark message as unread"
  end
end
