require File.dirname(__FILE__) + '/../spec_helper'
require 'base_helper'

describe "Widgets:", "the admin/menu_global widget" do
  include SpecViewHelper

  before :each do
    @user = stub_user
    template.stub!(:current_user).and_return @user

    helpers = [:admin_global_select_tag, :admin_site_select_tag,
               :admin_plugins_path, :admin_site_user_path,
               :admin_user_path, :logout_path, :link_to_profile]
    helpers.each do |helper| template.stub!(helper).and_return helper.to_s end
  end
  
  act! { render 'widgets/admin/_menu_global' }

  describe "when in multi-site mode" do
    before :each do
      @multi_sites_enabled, Site.multi_sites_enabled = Site.multi_sites_enabled, true
    end
    
    after :each do
      Site.multi_sites_enabled = @multi_sites_enabled
    end

    it "shows the admin site select menu" do
      template.should_receive(:admin_site_select_tag)
      act!
    end
  end

  describe "when not in multi-site mode" do
    before :each do
      @multi_sites_enabled, Site.multi_sites_enabled = Site.multi_sites_enabled, false
    end
    
    after :each do
      Site.multi_sites_enabled = @multi_sites_enabled
    end

    it "shows the admin site select menu" do
      template.should_not_receive(:admin_site_select_tag)
      act!
    end
  end

  it "shows the current user's name" do
    template.should_receive(:link_to_profile).with(nil, :name => @user.name).and_return('link to profile')
    act!
  end

  it "shows a link to the current user profile" do
    template.should_receive(:link_to_profile)
    act!
  end

  it "shows a logout link" do
    act!
    response.should have_tag('a[href=?]', "logout_path")
  end
end

describe "_navigation.html.erb" do
  before :each do
    template.stub!(:link_to).and_return('link')
    @site = mock_model(Site, :id => 1, :new_record? => false)
  end
  
  it "should use link_to_profile helper" do
    template.should_receive(:link_to_profile).and_return('link to profile')
    render 'widgets/admin/_navigation'
  end
end

describe "_utility.html.erb" do
  before :each do
    @user = mock_model(User, :id => 1, :name => 'Dummy')
    template.stub!(:current_user).and_return(@user)
    template.stub!(:link_to).and_return('link')
  end
  
  it "should use link_to_profile helper" do
    template.should_receive(:link_to_profile).with(nil, :name => @user.name).and_return('link to profile')
    render 'widgets/admin/_utility'
  end
end
