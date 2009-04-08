require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper" ))

class NewsletterIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! "site with newsletter"
    Newsletter.destroy_all
  end

  test "admin manages newsletters" do
    login_as_admin
    visit_newsletters
    submit_invalid_newsletter_and_fail
    submit_newsletter
  end

private

  def visit_newsletters
    visit "/admin/sites/#{@site.id}/newsletters"

    assert_template "admin/newsletters/index"
    response.body.should have_tag(".empty>a", /Create one now/)
  end

  def submit_invalid_newsletter_and_fail
    assert_template "admin/newsletters/index"
    click_link "New"

    assert_template "admin/newsletters/new"
    fill_in :newsletter_title, :with => nil
    fill_in :newsletter_desc, :with => nil
    click_button "Save"

    assert_template "admin/newsletters/new"
    response.body.should have_tag(".error_message")

    click_link "Newsletters"
  end

  def submit_newsletter
    assert_template "admin/newsletters/index"
    click_link "New"

    fill_in :newsletter_title, :with => "newsletter test title"
    fill_in :newsletter_desc, :with => "newsletter test desc"
    click_button "Save"

    assert_template "admin/newsletters/index"
    response.body.should have_tag("td>a", "newsletter test title")
  end
end

# FIXME implement these, if already implemented, delete these
#
# class NewsletterIntegrationTest < ActionController::IntegrationTest
  # def setup
    # super
    # @site = use_site! "site with newsletter"
    # login_as_admin

    # visit "/admin/sites/#{@site.id}/newsletters"
    # assert_template "admin/newsletters/index"
  # end

  # test "admin EDITS a new newsletter: should be SUCCESS" do
    # click_link "Edit"

    # assert_template "admin/newsletters/edit"
    # fill_in :newsletter_title, :with => "EDITED newsletter title"
    # fill_in :newsletter_desc, :with => "EDITED newsletter desc"
    # click_button "Save"

    # assert_template "admin/newsletters/index"
    # assert_flash "Newsletter has been updated successfully"
    # click_link "EDITED newsletter title"

    # assert_template "admin/issues/index"
    # # assert_select "h1>a", "EDITED newsletter title"
    # # assert_select "p", "EDITED newsletter desc"
  # end

  # test "admin DELETES a newsletter: should move it to TRASH" do
    # click_link "Delete"

    # assert_template "admin/newsletters/index"
    # assert_flash "Newsletter was successfully moved to trash"
    # assert_equal 0, @site.newsletters.count
    # assert_equal 1, @site.deleted_newsletters.count
  # end
# end
