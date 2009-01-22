require File.dirname(__FILE__) + "/../spec_helper"

describe RolesController do
  include Stubby
  include SpecControllerHelper

  before :each do
    stub_scenario :empty_site, :user_logged_in, :user_is_admin
    User.stub!(:find).and_return @user
  end

  it "page_caches the :index action" do
    cached_page_filter_for(:index).should_not be_nil
  end

  describe "GET to :index" do
    act! { request_to :get, '/users/1/roles.js' }
    it_assigns :user, :site, :roles
    it_renders_template :index, :format => :js
    it_gets_page_cached
    
    it "@roles should always include user role" do
      act!
      assigns[:roles].should include(Rbac::Role.build(:user))
    end
  end
end