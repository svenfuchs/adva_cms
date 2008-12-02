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
end