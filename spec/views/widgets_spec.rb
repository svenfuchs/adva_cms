require File.dirname(__FILE__) + '/../spec_helper'
require 'base_helper'

describe "Widgets:", "the admin/menu_global widget" do
  include SpecViewHelper
  
  describe "the link to the global user list" do
    before :each do
      @user = stub_user
      template.stub!(:current_user).and_return @user
      
      template.stub!(:site_select_tag).and_return('site_select_tag')
      template.stub!(:admin_plugins_path).and_return('admin_plugins_path')
      template.stub!(:admin_site_user_path).and_return('admin_site_user_path')
      template.stub!(:admin_user_path).and_return('admin_user_path')
      template.stub!(:logout_path).and_return('logout_path')
    end
  
    it "should be visible when the user is a superuser" do
      @user.should_receive(:has_role?).with(:superuser).and_return true
      render 'widgets/admin/_menu_global'
      response.should have_tag('a[href=?]', '/admin/users')
    end
    
    it "should not be visible when the user is not a superuser" do
      @user.should_receive(:has_role?).with(:superuser).and_return false
      render 'widgets/admin/_menu_global'
      response.should_not have_tag('a[href=?]', '/admin/users')
    end
  end
end