require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class InstallationTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers

  setup do
    Site.delete_all
    User.delete_all
  end
  
  test "user installs the initial site, manages the new site, logs out and views the empty frontend" do
    # go to root page
    get "/"

    # user should see the install template
    assert_template "admin/install/index"

    # fill in the form and submit the form
    fill_in :site_name,     :with => "adva-cms test"
    fill_in :user_email,    :with => "test@example.org"
    fill_in :user_password, :with => "test_password"
    fill_in :section_title, :with => "Home"
    click_button "Create"

    # check that a new site is created
    assert_equal 1, Site.count
    site = Site.first
    assert_not_nil site

    # check that root section is created
    assert_equal 1, site.sections.count
    assert_equal "Home", site.sections.first.title

    # check that admin account is created and verified
    assert_equal 1, User.count
    admin = User.first
    assert_not_nil admin
    assert admin.verified?

    # check that the system authenticates the user
    assert_equal admin, controller.current_user

    # check that the system authenticates the user as a superuser
    assert admin.has_role?(:superuser)
    
    # check that site has default email (same as user one for default)
    assert_equal admin.email, site.email
    
    # check that confirmation page has correct user attributes
    assert_select 'p#user_profile', /test@example.org/
    assert_select 'p#user_profile', /test_password/
    
    # go to admin main page
    get admin_site_path(Site.first)

    # check that the user sees the site dashboard
    assert_template "admin/sites/show"
    
    # logout
    click_link "Logout"

    # check that the user sees the frontend
    assert_template "sections/show"
    
    #check that the frontend contains the site title
    assert response.body =~ /adva-cms test/i, "frontend should contain site title"
  end
end
