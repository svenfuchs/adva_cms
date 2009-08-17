# FIXME break this up to smaller steps

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class InstallationTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers

  def setup
    super
    Site.delete_all
    User.delete_all
  end
  
  test "user should not be able to install the initial site without a valid email" do
    # go to root page
    get "/"

    # user should see the install template
    assert_template "admin/install/index"

    # fill in the form and submit the form
    fill_in :site_name,     :with => "adva-cms test"
    fill_in :user_email,    :with => "test"
    fill_in :user_password, :with => "test_password"
    fill_in :section_title, :with => "Home"
    click_button "Create"

    # check that a new site is created
    assert_equal 0, Site.count
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

    # check the admin's email
    assert_equal 'test@example.org', admin.email

    # check that site has default email (same as user one for default)
    assert_equal admin.email, site.email

    # go to admin main page
    get admin_site_path(Site.first)
    
    # check that the user sees the site dashboard
    assert_template "admin/sites/show"
    
    # logout
    click_link "Logout"

    # check that the user sees the frontend
    assert_template "pages/articles/index"

    #check that the frontend contains the site title
    assert response.body =~ /adva-cms test/i, "frontend should contain site title"
  end
  
  test "user installs the initial site with blog section and different section title (fix for bug #293)" do
    # go to root page
    get "/"

    # user should see the install template
    assert_template "admin/install/index"

    # fill in the form and submit the form
    fill_in :site_name,     :with => "adva-cms test"
    fill_in :user_email,    :with => "test@example.org"
    fill_in :user_password, :with => "test_password"
    select  'Blog',         :from => "section_type"
    fill_in :section_title, :with => "Blog"
    click_button "Create"

    # check that root section is created and it is a blog and has the title user defined
    site = Site.first
    assert_equal Blog, site.sections.first.class
    assert_equal "Blog", site.sections.first.title
  end
end
