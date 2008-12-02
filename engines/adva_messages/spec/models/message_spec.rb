require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  
  before :each do
    @message = Factory :message
    @johan   = @message.sender
    @don     = @message.recipient
  end

  describe "associations:" do  
    it "belongs to sender" do
      @message.should belong_to(:sender)
    end
    
    it "belongs to recipient" do
      @message.should belong_to(:recipient)
    end
    
    it "belongs to conversation" do
      @message.should belong_to(:conversation)
    end
  end
  
  describe "validations:" do
    it "should validate the presence of subject" do
      @message.subject = nil
      @message.should_not be_valid
    end
    
    it "should validate the presence of message body" do
      @message.body = nil
      @message.should_not be_valid
    end
    
    it "should validate the presence of recipient" do
      @message.recipient = nil
      @message.should_not be_valid
    end
    
    it "should validate the presence of sender" do
      @message.sender = nil
      @message.should_not be_valid
    end
  end
  
  describe "class methods:" do
    describe "#reply_to" do
      before :each do
        @new_message = Message.reply_to(@message)
      end
      
      it "returns a message object that has a predifined recipient" do
        @new_message.recipient.should == @johan
      end
      
      it "returns a message object that has a predifined subject" do
        @new_message.subject.should == "Re: " + @message.subject
      end
      
      it "does not add another Re: to a subject if message already starts with Re:" do
        @new_message = Message.reply_to(@new_message)
        @new_message.subject.should == "Re: " + @message.subject
      end
      
      it "returns a message object that has a predefined parent_id" do
        @new_message.parent_id.should == @message.id
      end
    end
  end
  
  describe "methods:" do
    describe "#parent" do
      before :each do
        @parent_message = Factory :message
        @message_with_parent = Factory :message, :parent_id => @parent_message.id
      end
      
      it "returns the parent message" do
        @message_with_parent.parent.should == @parent_message
      end
      
      it "returns nil when there is no parent" do
        @message.parent.should be_nil
      end
    end
    
    describe "#is_reply?" do
      it "returns true when message is a  reply" do
        @message.update_attribute(:parent_id, 1)
        @message.is_reply?.should be_true
      end
      
      it "returns false when message is not a reply" do
        @message.update_attribute(:parent_id, nil)
        @message.is_reply?.should be_false
      end
    end
    
    describe "#mark_as_read" do
      before :each do
        @message.update_attribute(:read_at, nil)
      end
      
      it "marks the message as read" do
        @message.mark_as_read
        @message.read_at.should_not be_nil
      end
    end
    
    it "#mark_as_unread marks the message as unread"
    
    describe "#mark_as_deleted" do
      describe "when user is sender and receiver" do
        before :each do
          @message.recipient = @johan
        end
        
        it "marks the message as deleted for sender" do
          @message.mark_as_deleted(@johan)
          @message.deleted_at_sender.should_not be_nil
        end
        
        it "marks the message as deleted for receiver" do
          @message.mark_as_deleted(@johan)
          @message.deleted_at_recipient.should_not be_nil
        end
      end
      
      describe "when user is sender" do
        it "marks the message as deleted for sender" do
          @message.mark_as_deleted(@johan)
          @message.deleted_at_sender.should_not be_nil
        end
        
        it "does not mark the message as deleted for receiver" do
          @message.mark_as_deleted(@johan)
          @message.deleted_at_recipient.should be_nil
        end
      end
      
      describe "when user is receiver" do
        before :each do
          @message.recipient = @johan
          @message.sender    = @don
        end
        
        it "marks the message as deleted for receiver" do
          @message.mark_as_deleted(@johan)
          @message.deleted_at_recipient.should_not be_nil
        end
        
        it "does not mark the message as deleted for sender" do
          @message.mark_as_deleted(@johan)
          @message.deleted_at_sender.should be_nil
        end
      end
    end
  end
  
  describe "before_create" do
    describe "#assign_to_conversation" do
      before :each do
        @don_macaroni = Factory :don_macaroni
        @johan_mcdoe  = Factory :johan_mcdoe
      end
      describe "when message is a new message" do
        before :each do
          @message = Message.create!(:subject => 'test', :body => 'test body',
                                     :sender => @johan_mcdoe, :recipient => @don_macaroni)
        end
        
        it "assigns a conversation object for message" do
          @message.conversation.should be_kind_of(Conversation)
        end
        
        it "has only the newly created message on conversation" do
          @message.conversation.messages.count == 1
        end
      end
      
      describe "when message is a reply to another message" do
        before :each do
          @message = Message.create!(:subject => 'test', :body => 'test body',
                                     :sender => @johan_mcdoe, :recipient => @don_macaroni)
          @new_message        = Message.reply_to(@message)
          @new_message.body   = 'reply body'
          @new_message.sender = @don_macaroni
        end
        
        it "assigns the message to parent messages conversation" do
          @new_message.save!
          @new_message.conversation_id.should == @message.conversation_id
        end
      end
    end
  end
end