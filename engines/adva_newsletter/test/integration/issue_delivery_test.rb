require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper" ))

class IssueDeliverieIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! "site with newsletter"
    @newsletter = @site.newsletters.first
    @issue = @newsletter.issues.first

    @issue.draft = 0
    @issue.save
  end

  def teardown
    super
    remove_all_test_cronjobs
  end

  test "admin manages issue deliveries" do
    login_as_admin
    visit_issue
    send_all_now
    cancel_delivery
    send_all_later
    try_to_cancel_delivery_when_delivered
  end

private

  def visit_issue
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/#{@issue.id}"

    assert_template "admin/issues/show"
    response.body.should have_tag("p.state", "On hold")
  end

  def send_all_now
    assert_template "admin/issues/show"
    click_button "Send now"

    assert_template "admin/issues/show"
    assert_flash "Issue was successfully added to the delivery queue"
  end

  def cancel_delivery
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

  def try_to_cancel_delivery_when_delivered
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

  def send_all_later
    assert_template "admin/issues/show"
    click_button "Send later"

    assert_template "admin/issues/show"
    assert_flash "Issue was successfully added to the queue to deliver later"
  end

  def send_preview
    assert_template "admin/issues/show"
    click_link "Send preview"

    # TODO: we need selenium tests
  end
end
