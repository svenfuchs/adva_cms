require File.expand_path(File.join(File.dirname(__FILE__), "../..", "test_helper" ))

class IssueDeliverieIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! "site with newsletter"
    @newsletter = @site.newsletters.first
    @issue = @newsletter.issues.first

    @issue.draft = 0
    @issue.save

    login_as_admin
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/#{@issue.id}"
    assert_template "admin/issues/show"
    response.body.should have_tag("p.state", "On hold")
  end

  def teardown
    super
    remove_all_test_cronjobs
  end

  test "send all now" do
    click_button "Send now"

    assert_template "admin/issues/show"
    assert_flash "Issue was successfully added to the delivery queue"
  end

  test "cancel delivery" do
    click_button "Send now"

    assert_template "admin/issues/show"
    click_button "Cancel delivery"

    assert_template "admin/issues/show"
    assert_flash "Delivery was successfully cancelled"
    response.body.should have_tag("#issue") do |issue|
      issue.should have_tag("h2", "issue title")
      issue.should have_tag("span.state", "On hold")
      issue.should have_tag("p", "issue body")
    end
  end

  test "try to cancel delivery when delivered" do
    click_button "Send now"
    @issue.queued_state!
    @issue.delivered_state!
    @issue.state.should == "delivered"

    assert_template "admin/issues/show"
    click_button "Cancel delivery"

    assert_template "admin/issues/show"
    assert_flash "Cannot cancel delivery because the issue has already been delivered."
    response.body.should have_tag("#issue") do |issue|
      issue.should have_tag("h2", "issue title")
      issue.should have_tag("span.state", "On hold")
      issue.should have_tag("p", "issue body")
    end
  end

  test "send all later" do
    assert_template "admin/issues/show"
    click_button "Send later"

    assert_template "admin/issues/show"
    assert_flash "Issue was successfully added to the queue to deliver later"
  end

  test "send preview" do
    # TODO: we need selenium tests
  end
end
