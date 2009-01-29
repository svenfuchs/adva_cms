require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper" ))

class IssueDeliveriesTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter_and_issue
    login_as :admin
    @other_user = Factory :other_user

    # TODO: perhaps factory has some better way for poly
    @subscription = Subscription.new(:user_id => @other_user.id)
    @subscription.subscribable_id = 1
    @subscription.subscribable_type = "Newsletter"
    @subscription.save
    @issue.draft = 0
    @issue.save

    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/#{@issue.id}"

    assert_template "admin/issues/show"
    assert_select "p.state", "On hold"
  end

  test "admin SENDS NOW: should be added to delivery queue" do
    click_button "Send now"

    assert_template "admin/issues/show"
    assert_flash "Newsletter issue was successfully added to the delivery queue"
  end
  
  test "admin SENDS WITH DELAY: should be added to delivery queque with delay (deliver mocked)" do
    click_button "Send later"

    assert_template "admin/issues/show"
    assert_flash "Newsletter issue was successfully added to the queue to send out later"
  end

  test "admin sends PREVIEW issue: should send issue only to myself" do
    # click_link "Send preview"
    # TODO: we need selenium tests
  end
end
