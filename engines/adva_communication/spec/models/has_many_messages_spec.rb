require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before :each do
    @user = User.new
  end
  
  it "should have many received messages" do
    @user.should have_many(:messages_received)
  end
  
  it "should have many sent messages" do
    @user.should have_many(:messages_sent)
  end
end