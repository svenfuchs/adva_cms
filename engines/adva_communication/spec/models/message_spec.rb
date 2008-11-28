require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  
  before :each do
    @message = Message.new
  end
  
  it "is kind of communication" do
     @message.should be_kind_of(Communication)
  end

  describe "associations:" do  
    it "belongs to sender" do
      @message.should belong_to(:sender)
    end
    
    it "belongs to recipient" do
      @message.should belong_to(:recipient)
    end
  end
  
  describe "methods:" do
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
      describe "when user is sender" do
        before :each do
          @user     = Factory :user
          @message  = Factory :message, :sender_id => @user.id
        end
        
        it "marks the message as deleted for sender" do
          @message.mark_as_deleted(@user)
          @message.deleted_at_sender.should_not be_nil
        end
        
        it "does not mark the message as deleted for receiver" do
          @message.mark_as_deleted(@user)
          @message.deleted_at_recipient.should be_nil
        end
      end
      
      describe "when user is receiver" do
        before :each do
          @user     = Factory :user
          @message  = Factory :message, :recipient_id => @user.id
        end
        
        it "marks the message as deleted for receiver" do
          @message.mark_as_deleted(@user)
          @message.deleted_at_recipient.should_not be_nil
        end
        
        it "does not mark the message as deleted for sender" do
          @message.mark_as_deleted(@user)
          @message.deleted_at_sender.should be_nil
        end
      end
    end
  end
end