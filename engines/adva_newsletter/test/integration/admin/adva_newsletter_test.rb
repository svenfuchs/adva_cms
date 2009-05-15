require File.expand_path(File.join(File.dirname(__FILE__), "../..", "test_helper" ))

class AdvaNewsletterIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! "site with newsletter"
    login_as_admin
    visit "/admin/sites/#{@site.id}/newsletters"
    assert_template "admin/newsletters/index"
  end
  
  test "admin visits newsletters, should see index with empty message" do
    Adva::Newsletter.destroy_all
    visit "/admin/sites/#{@site.id}/newsletters"
    assert_template "admin/newsletters/index"
    response.body.should have_tag(".empty>a", /Create one now/)
  end
  
  test "admin submits invalid newsletter, should fail with error messages" do
    click_link "New"

    assert_template "admin/newsletters/new"
    fill_in :newsletter_title, :with => nil
    fill_in :newsletter_desc, :with => nil
    click_button "Save"

    assert_template "admin/newsletters/new"
    response.body.should have_tag(".error_message")
  end
  
  test "admin submits newsletter, should be success and show new item at index" do
    click_link "New"

    assert_template "admin/newsletters/new"
    fill_in :newsletter_title, :with => "newsletter test title"
    fill_in :newsletter_desc, :with => "newsletter test desc"
    click_button "Save"

    assert_template "admin/newsletters/index"
    response.body.should have_tag("td>a", "newsletter test title")
  end

  test "admin EDITS a new newsletter: should be SUCCESS" do
    click_link "Edit"

    assert_template "admin/newsletters/edit"
    fill_in :newsletter_title, :with => "EDITED newsletter title"
    fill_in :newsletter_desc, :with => "EDITED newsletter desc"
    click_button "Save"

    assert_template "admin/newsletters/index"
    assert_flash "Newsletter has been updated successfully"
  end

  test "admin DELETES a newsletter" do
    #TODO we need selenium test
  end
end
