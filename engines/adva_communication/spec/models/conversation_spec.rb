require File.dirname(__FILE__) + '/../spec_helper'

describe Conversation do
  before :each do
    @conversation = Conversation.new
  end
  
  describe "associations:" do
    it "should have many messages" do
      @conversation.should have_many(:messages)
    end
  end
  
  describe "methods:" do
    before :each do
      @conversation                = Factory :conversation
      @conversation.messages.create Factory.attributes_for(:message)
      @conversation.messages.create Factory.attributes_for(:reply)
    end
    
    describe "#mark_messages_as_read" do
      it "marks all the messages as read" do
        @conversation.mark_messages_as_read
        @conversation.messages.each do |message|
          message.read_at.should_not be_nil
        end
      end
    end
  end
end