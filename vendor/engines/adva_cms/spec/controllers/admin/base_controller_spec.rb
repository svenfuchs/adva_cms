require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::SitesController do
  include SpecControllerHelper

  before :each do
    scenario :empty_site
    controller.stub!(:guard_permission)
  end
  
  describe "#require_authentication" do
    it "redirects to login_url when user is not logged in" do
      controller.stub!(:current_user).and_return User.new
      request_to :get, '/admin/sites'
      response.should redirect_to(login_url)
    end
    
    it "updates current_role_context" do
      controller.should_receive(:update_role_context!).with({"action"=>"index", "controller"=>"admin/sites"})
      request_to :get, '/admin/sites'
      response.should redirect_to(login_url)
    end
  end
end

describe Admin::SitesController, "with logged in user " do
  include SpecControllerHelper
  
  before :each do
    scenario :empty_site
    scenario :user_logged_in
    controller.stub!(:guard_permission)
    controller.stub!(:current_user).and_return(@user)
  end
  
  describe "#require_authentication on /admin " do
    it "does not raise an error" do
      lambda { request_to(:get, '/admin') }.should_not raise_error
    end
  
    it "succeeds when user accesses the /admin area" do
      @role = Rbac::Role.build(:admin, :context => Site.new)
      Rbac::Role.stub!(:build).and_return(@role)
      @role.stub!(:granted_to?).and_return(true)
      
      request_to :get, '/admin'
      response.should be_success
    end
    
    it "uses current_role_context for context of a role" do
      @user.stub!(:has_role?).and_return(true)
      controller.stub!(:update_role_context!)
      
      controller.should_receive(:current_role_context)
      controller.send :require_authentication
    end
  end
end