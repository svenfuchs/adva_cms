require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    super
    @subscription = Adva::Subscription.new(:user_id => User.first.id)
  end

  test "should be valid" do
    @subscription.should be_valid
  end

  test "validates presence of user_id" do
    # FIXME figure out how nested attributes can deal with requiring user_id with mass assignment
    # @subscription.should validate_presence_of(:user_id)
  end

  test "should validate uniqueness of user_id in the scope of the associated subscribable" do
    @subscription.should validate_uniqueness_of(:user_id, :scope => [:subscribable_id, :subscribable_type])
  end

  # confirmed scope
  test "only returns confirmed subscriptions (double opt-in)" do
    Adva::Subscription.confirmed.proxy_options[:conditions].should == "confirmed_at IS NOT NULL"
  end
end
