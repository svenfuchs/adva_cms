require File.dirname(__FILE__) + '/../spec_helper'

describe Subscription do
  before do
    @user = Factory :user
    @subscription = Subscription.new(:user_id => @user.id)
  end

  describe "validations:" do
    it "should be valid" do
      @subscription.should be_valid
    end
    
    it "should validate uniqueness of user_id" do
      @subscription.should validate_uniqueness_of(:user_id) # :scope => :subscribable_id
    end
  end
end
