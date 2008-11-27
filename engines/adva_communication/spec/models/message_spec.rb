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
    it "#mark_as_read marks the message as read"
    
    it "#mark_as_unread marks the message as unread"
    
    describe "#mark_as_deleted" do
      describe "when user is sender" do
        it "marks the message as deleted for sender"
        
        it "does not mark the message as deleted for receiver"
      end
      
      describe "when user is receiver" do
        it "marks the message as deleted for receiver"
        
        it "does not mark the message as deleted for sender"
      end
    end
  end
end