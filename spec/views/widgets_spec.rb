require File.dirname(__FILE__) + '/../spec_helper'
require 'base_helper'

describe "Widgets:", "the admin/menu_global widget" do
  include SpecViewHelper

  before :each do
    I18n.locale = :en
    Thread.current['site'] = stub_site

    @user = stub_user
    template.stub!(:current_user).and_return @user

    helpers = [:admin_global_select_tag, :admin_site_select_tag,
               :admin_plugins_path, :admin_site_user_path,
               :admin_user_path, :logout_path]
    helpers.each do |helper| template.stub!(helper).and_return helper.to_s end
  end
  act! { render 'widgets/admin/_menu_global' }

  describe "when the user is a superuser" do
    before :each do
      @user.stub!(:has_role?).with(:superuser).and_return true
    end


    it "shows the admin site select menu" do
      template.should_receive(:admin_site_select_tag)
      act!
    end
  end

  describe "when the user is not a superuser" do
    before :each do
      @user.stub!(:has_role?).with(:superuser).and_return false
    end

    it "shows the admin site select menu" do
      template.should_receive(:admin_site_select_tag)
      act!
    end
  end

  it "shows the current user's name" do
    act!
    response.should have_text(/#{@user.name}/)
  end

  it "shows a link to the current user profile" do
    act!
    response.should have_tag('a[href=?]', "admin_user_path")
  end

  it "shows a logout link" do
    act!
    response.should have_tag('a[href=?]', "logout_path")
  end
end
