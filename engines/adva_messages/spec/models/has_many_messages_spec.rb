require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before :each do
    @user             = Factory :user
    @message_sent     = Factory :message, :sender_id    => @user.id
    @message_received = Factory :message, :recipient_id => @user.id
  end
  
  describe "associations:" do  
    it "should have many received messages" do
      @user.should have_many(:messages_received)
    end
  
    it "should have many sent messages" do
      @user.should have_many(:messages_sent)
    end
    
    # it "should have many conversations" do
    #   @user.should have_many(:conversations)
    # end
    # 
    # it "should have many sent conversations" do
    #   @user.should have_many(:conversations_sent)
    # end
  end
  
  describe "#messages_received" do
    it "returns only messages where user is recipient" do
      @user.messages_received.should == [@message_received]
    end
    
    it "does not return messages where user is recipient if they are deleted" do
      @message_received.update_attribute(:deleted_at_recipient, Time.now)
      @user.messages_received.should_not == [@message_deleted]
    end
  end
  
  describe "#messages_sent" do
    it "returns only messages where user is sender" do
      @user.messages_sent.should == [@message_sent]
    end
    
    it "does not return messages where user is sender if they are deleted" do
      @message_sent.update_attribute(:deleted_at_sender, Time.now)
      @user.messages_sent.should_not == [@message_sent]
    end
  end
end