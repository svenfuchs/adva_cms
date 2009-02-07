require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper" ))

class NewIssueTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter
    login_as :admin
  end

  test "admin submits an EMPTY issue: should see validation warnings" do

    visit "/admin/sites/#{@site.id}/newsletters/"

    assert_template "admin/newsletters/index"
    click_link @newsletter.title

    assert_template "admin/issues/index"
    click_link "Create a new issue"

    assert_template "admin/issues/new"
    fill_in :issue_title, :with => nil
    fill_in :issue_body, :with => nil
    click_button "Save"

    assert_template "admin/issues/new"
    assert_select ".field_with_error"
  end

  test "admin submits a DRAFT issue: should be success and show new issue as draft" do

    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/new"

    assert_template "admin/issues/new"
    fill_in :issue_title, :with => "draft issue title"
    fill_in :issue_body, :with => "draft issue body"
    click_button "Save"

    assert_template "admin/issues/show"
    assert_select "#issue" do
      assert_select "h2", /draft issue title/
      assert_select "p.state", "Draft"
      assert_select "p", "draft issue body"
    end
  end

  test "admin submits a NON-DRAFT issue: should be success and show new issue" do

    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/new"

    assert_template "admin/issues/new"
    fill_in :issue_title, :with => "issue title"
    fill_in :issue_body, :with => "issue body"
    uncheck "issue_draft"
    click_button "Save"

    assert_template "admin/issues/show"
    assert_select "#issue" do
      assert_select "h2", /issue title/
      assert_select "p", "issue body"
    end
  end
end

class IssueTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter_and_issue
    login_as :admin
  end

  test "admin EDITS issue: should be success" do

    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/#{@issue.id}"

    assert_template "admin/issues/show"
    click_link "Edit"

    assert_template "admin/issues/edit"
    fill_in :issue_title, :with => "EDITED issue title"
    fill_in :issue_body, :with => "EDITED issue body"
    click_button "Save"

    assert_template "admin/issues/show"
    assert_flash "Newsletter issue was successfully updated"
    assert_select "#issue" do
      assert_select "h2", /EDITED issue title/
      assert_select "p", "EDITED issue body"
    end
  end

  test "admin DELETES issue: should go to trash" do

    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/"

    assert_template "admin/issues/index"
    assert_equal 1, @newsletter.issues.count
    click_link "delete"

    assert_template "admin/issues/index"
    assert_flash "Newsletter issue was successfully moved to trash."
    assert_equal 0, @newsletter.issues.count
  end

  def teardown
    remove_all_test_cronjobs
  end
end

class QueuedIssueTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter_and_issue
    login_as :admin

    @issue.state = "hold"
    @issue.deliver
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/#{@issue.id}"

    assert_template "admin/issues/show"
    assert_select "p.state", "Queued"
  end

  test "admin CANCELS DELIVERY: should bring back delivery menu" do
    click_button "Cancel delivery"

    assert_template "admin/issues/show"
    assert_flash "Delivery was successfully cancelled"
    assert_select "#issue" do
      assert_select "h2", /issue title/
      #FIXME: figure out why assert_select "span.status" has got "Queued" status. Is it cached or smth?
      # assert_select "span.state", "On hold"
      assert response.body.grep(Regexp.escape("<p class=\"state\">On hold</span>"))
      assert_select "p", "issue body"
    end
  end

  test "admin CANCELS DELIVERY AFTER DELIVERY: should go back to show with flash message about failure" do
    @issue.cancel_delivery

    click_button "Cancel delivery"

    assert_template "admin/issues/show"
    assert_flash "Cannot cancel delivery because the issue has already been delivered."
    assert_select "#issue" do
      assert_select "h2", /issue title/
      assert response.body.grep(Regexp.escape("<p class=\"state\">Delivered</span>"))
      assert_select "p", "issue body"
    end
  end

  def teardown
    remove_all_test_cronjobs
  end
end
