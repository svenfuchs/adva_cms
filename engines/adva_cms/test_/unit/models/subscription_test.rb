require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    super
    @subscription = Subscription.new :user_id => User.first.id
  end

  test "should be valid" do
    # FIXME implement matcher?
    # @subscription.should be_valid
    assert @subscription.valid?
  end
  
  test "validates presence of user_id" do
    @subscription.should validate_presence_of(:user_id)
  end
  
  test "should validate uniqueness of user_id" do
    @subscription.should validate_uniqueness_of(:user_id, :scope => :subscribable_id)
  end
end
