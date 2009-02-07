require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::BaseHelper do
  include Stubby

  before :each do
    @user = stub_user
    helper.stub!(:current_user).and_return @user

    helper.stub!(:admin_sites_path).and_return 'admin_sites_path'
    helper.stub!(:admin_users_path).and_return 'admin_users_path'
    helper.stub!(:admin_site_path).and_return 'admin_site_path'

    helper.stub!(:request).and_return mock('request', :path => 'path')
  end

  describe "#admin_site_select_tag" do

    describe "if user is a superuser" do
      before :each do
        @user.stub!(:has_role?).with(:superuser).and_return true
      end

      it "shows the site overview option in the site select menu" do
        helper.admin_site_select_tag.should have_tag('select#site_select option[value=?]', 'admin_sites_path')
      end

      it "shows the user manager option in the site select menu" do
        helper.admin_site_select_tag.should have_tag('select#site_select option[value=?]', 'admin_users_path')
      end
    end

    describe "if user is not a superuser" do
      before :each do
        @user.stub!(:has_role?).with(:superuser).and_return false
      end

      it "shows the site overview option in the site select menu" do
        helper.admin_site_select_tag.should_not have_tag('select#site_select option[value=?]', 'admin_sites_path')
      end

      it "shows the user manager option in the site select menu" do
        helper.admin_site_select_tag.should_not have_tag('select#site_select option[value=?]', 'admin_users_path')
      end
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::BaseHelper do
  
  before :each do
    @user = mock_model(User, :id => 1)
    @user.stub!(:has_role?).with(:superuser).and_return false
    @site = mock_model(Site, :id => 1)
    helper.stub!(:current_user).and_return(@user)
  end
  
  it "should return admin/sites/1/users/1 as a profile link if site is set" do
    helper.link_to_profile(@site).should == "<a href=\"/admin/sites/1/users/1\">Profile</a>"
  end
  
  it "should return admin/users/1 as a profile link if no site is set" do
    helper.link_to_profile.should == "<a href=\"/admin/users/1\">Profile</a>"
  end
  
  it "should return admin/users/1 as a profile link if site is a new record" do
    helper.link_to_profile(Site.new).should == "<a href=\"/admin/users/1\">Profile</a>"
  end
  
  it "should return custom link name for profile if specified" do
    helper.link_to_profile(Site.new, :name => 'Dummy').should == "<a href=\"/admin/users/1\">Dummy</a>"
  end
  
  it "should return admin/users/1 as a profile link if site is set but user is a superuser" do
    @user.should_receive(:has_role?).with(:superuser).and_return true
    helper.link_to_profile(@site).should == "<a href=\"/admin/users/1\">Profile</a>"
  end
end
