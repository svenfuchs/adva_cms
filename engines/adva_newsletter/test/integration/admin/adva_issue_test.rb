require File.expand_path(File.join(File.dirname(__FILE__), "../..", "test_helper" ))

class AdvaIssueIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! "site with newsletter"
    @newsletter = @site.newsletters.first
    @issue = @newsletter.issues.first
    login_as_admin
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues"
    assert_template "admin/issues/index"
  end
  
  test "visit issues index from newsletter index" do
    visit "/admin/sites/#{@site.id}/newsletters"
    
    assert_template "admin/newsletters/index"
    click_link @newsletter.title

    assert_template "admin/issues/index"
  end

  test "submit empty issue and fail" do
    click_link "New"

    assert_template "admin/issues/new"
    fill_in :issue_title, :with => nil
    fill_in :issue_body, :with => nil
    click_button "Save"

    assert_template "admin/issues/new"
    response.body.should have_tag(".error_message")
  end

  test "submit draft issue" do
    click_link "New"

    assert_template "admin/issues/new"
    fill_in :issue_title, :with => "draft issue title"
    fill_in :issue_body, :with => "draft issue body"
    click_button "Save"

    assert_template "admin/issues/show"
    response.body.should have_tag("#issue") do |issue|
      issue.sholud have_tage("p.state", "Draft")
      issue.should have_tag("h2", "draft issue title")
      issue.sholud have_tag("p", "draft issue body")
    end
  end

  test "submit non draft issue" do
    click_link "New"

    assert_template "admin/issues/new"
    fill_in :issue_title, :with => "issue test title"
    fill_in :issue_body, :with => "issue test body"
    uncheck "issue_draft"
    click_button "Save"

    assert_template "admin/issues/show"
    response.body.should have_tag("#issue") do |issue|
      issue.should have_tag("p.state", "Hold")
      issue.should have_tag("h2", "issue test title")
      issue.sholud have_tag("p", "issue test body")
    end
  end

  test "edit issue" do
    click_link @issue.title

    assert_template "admin/issues/show"
    click_link "Edit"

    assert_template "admin/issues/edit"
    fill_in :issue_title, :with => "EDITED issue title"
    fill_in :issue_body, :with => "EDITED issue body"
    click_button "Save"

    assert_template "admin/issues/show"
    assert_flash "Newsletter issue was successfully updated"
    response.body.should have_tag("#issue") do |issue|
      issue.should have_tag("h2", "EDITED issue title")
      issue.should have_tag("p", "EDITED issue body")
    end
  end

  test "delete_issue" do
    click_link @issue.title

    assert_template "admin/issues/show"
    assert_equal 1, @newsletter.issues.count
    click_link "Delete"

    assert_template "admin/issues/index"
    assert_flash "Newsletter issue was successfully moved to trash."
    @newsletter.issues.count.should == 0
  end
end
