require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class InstallationTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers

  def setup
    Site.delete_all
    User.delete_all
  end

  def test_a_user_installs_the_initial_site_and_then_logs_out_and_views_the_empty_frontend
    # go to root page
    get "/"

    # user should see the install template
    assert_template "admin/install/index"

    # fill in the form and submit the form
    fills_in "website name",  :with => "adva-cms Test"
    fills_in "website title", :with => "adva-cms Testsite"
    fills_in "title",         :with => "Home"
    clicks_button "Create"

    # check that a new site is created
    assert_equal 1, Site.count
    @site = Site.first
    assert_not_nil @site

    # check that root section is created
    assert_equal 1, @site.sections.count
    assert_equal "Home", @site.sections.first.title

    # check that admin account is created and verified
    assert_equal 1, User.count
    
    @admin = User.find_by_first_name('admin')
    assert_not_nil @admin
    assert @admin.verified?

    # check that the system authenticates the user
    assert_equal @admin, controller.current_user

    # check that the system authenticates the user as a superuser
    assert @admin.has_role?(:superuser)

    #puts response.inspect

    # go to admin main page and then log out
    clicks_link "Manage your new site &raquo;"
    clicks_link "Logout"

    # check that the user sees the frontend
    assert_template "sections/show"
    
    #check that the frontend contains the site title
    assert response.body =~ /adva-cms Testsite/, "frontend should contain site title"
  end
end