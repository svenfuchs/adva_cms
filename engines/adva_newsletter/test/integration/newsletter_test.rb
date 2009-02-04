require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper" ))

class EmptyNewsletterIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! "site with newsletter"
    login_as_admin

    Newsletter.destroy_all
    visit "/admin/sites/#{@site.id}/newsletters"
    assert_template 'admin/newsletters/index'
  end

  test "admin visits index: should NOT have a list, should have link for creating a newsletter" do
    assert_select '.empty'
    assert_select '.empty>a', 'Create a newsletter'
  end

  test "admin submits a INVALID newsletter: should see validation WARNINGS" do
    click_link "Create a newsletter"
    assert_template 'admin/newsletters/new'

    fill_in :newsletter_title, :with => nil
    fill_in :newsletter_desc, :with => nil
    click_button 'Save'

    assert_template 'admin/newsletters/new'
    assert_select '.field_with_error'
  end

  test "admin submits a VALID newsletter: should be SUCCESS" do
    click_link "Create a newsletter"
    assert_template 'admin/newsletters/new'

    fill_in :newsletter_title, :with => 'newsletter title'
    fill_in :newsletter_desc, :with => 'newsletter desc'
    click_button 'Save'

    assert_template 'admin/newsletters/index'
    click_link 'newsletter title'
    
    assert_template 'admin/issues/index'
  end
end

class NewsletterIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! "site with newsletter"
    login_as_admin

    visit "/admin/sites/#{@site.id}/newsletters"
    assert_template 'admin/newsletters/index'
  end

  test "admin EDITS a new newsletter: should be SUCCESS" do
    click_link 'Edit'
    
    assert_template 'admin/newsletters/edit'
    fill_in :newsletter_title, :with => 'EDITED newsletter title'
    fill_in :newsletter_desc, :with => 'EDITED newsletter desc'
    click_button 'Save'

    assert_template 'admin/newsletters/index'
    assert_flash "Newsletter has been updated successfully"
    click_link 'EDITED newsletter title'  
    
    assert_template 'admin/issues/index'
    # assert_select 'h1>a', 'EDITED newsletter title'
    # assert_select 'p', 'EDITED newsletter desc'
  end
  
  test "admin DELETES a newsletter: should move it to TRASH" do
    click_link 'Delete'

    assert_template 'admin/newsletters/index'
    assert_flash 'Newsletter was successfully moved to trash'
    assert_equal 0, @site.newsletters.count
    assert_equal 1, @site.deleted_newsletters.count
  end
end
