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
        helper.admin_site_select_tag.should have_tag('select#site-select option[value=?]', 'admin_sites_path')
      end

      it "shows the user manager option in the site select menu" do
        helper.admin_site_select_tag.should have_tag('select#site-select option[value=?]', 'admin_users_path')
      end
    end

    describe "if user is not a superuser" do
      before :each do
        @user.stub!(:has_role?).with(:superuser).and_return false
      end

      it "shows the site overview option in the site select menu" do
        helper.admin_site_select_tag.should_not have_tag('select#site-select option[value=?]', 'admin_sites_path')
      end

      it "shows the user manager option in the site select menu" do
        helper.admin_site_select_tag.should_not have_tag('select#site-select option[value=?]', 'admin_users_path')
      end
    end
  end
end
