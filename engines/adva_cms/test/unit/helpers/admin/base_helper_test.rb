require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class AdminBaseHelperTest < ActiveSupport::TestCase
  include Admin::BaseHelper
  
  include ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper
  
  attr_accessor :request
  
  def setup
    super
    @site = Site.first
    stub(self).current_user.returns User.new

    stub(self).admin_sites_path.returns 'admin_sites_path'
    stub(self).admin_site_user_path.returns 'admin_site_user_path'
    stub(self).admin_users_path.returns 'admin_users_path'
    stub(self).admin_user_path.returns 'admin_user_path'
    
    @controller = ActionView::TestController.new
    @request = ActionController::TestRequest.new
  end
  
  # admin_site_select_tag
  test "#admin_site_select_tag with current user being a superuser 
        it shows the site overview option in the site select menu" do
    stub(current_user).has_role?(:superuser).returns true
    admin_site_select_tag.should have_tag('select#site-select option[value=?]', 'admin_sites_path')
  end

  test "#admin_site_select_tag with current user being a superuser 
        it shows the user manager option in the site select menu" do
    stub(current_user).has_role?(:superuser).returns true
    admin_site_select_tag.should have_tag('select#site-select option[value=?]', 'admin_users_path')
  end
  
  test "#admin_site_select_tag with current user not being a superuser 
      it shows the site overview option in the site select menu" do
    admin_site_select_tag.should_not have_tag('select#site-select option[value=?]', 'admin_sites_path')
  end
  
  test "#admin_site_select_tag with current user not being a superuser 
      it shows the user manager option in the site select menu" do
    admin_site_select_tag.should_not have_tag('select#site-select option[value=?]', 'admin_users_path')
  end
  
  # link_to_profile
  test "#link_to_profile returns admin/sites/1/users/1 as a profile link if site is set" do
    link_to_profile(@site).should == "<a href=\"admin_site_user_path\">Profile</a>"
  end

  test "#link_to_profile returns admin/users/1 as a profile link if no site is set" do
    link_to_profile.should == "<a href=\"admin_user_path\">Profile</a>"
  end

  test "#link_to_profile returns admin/users/1 as a profile link if site is a new record" do
    link_to_profile(Site.new).should == "<a href=\"admin_user_path\">Profile</a>"
  end

  test "#link_to_profile returns custom link name for profile if specified" do
    link_to_profile(Site.new, :name => 'Dummy').should == "<a href=\"admin_user_path\">Dummy</a>"
  end

  test "#link_to_profile returns admin/users/1 as a profile link if site is set but user is a superuser" do
    stub(current_user).has_role?(:superuser).returns true
    link_to_profile(@site).should == "<a href=\"admin_user_path\">Profile</a>"
  end
end
