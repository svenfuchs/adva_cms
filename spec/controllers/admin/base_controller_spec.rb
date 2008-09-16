require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::SitesController do
  include SpecControllerHelper

  before :each do
    scenario :empty_site
    controller.stub!(:guard_permission)
  end

  describe "#require_authentication" do
    it "redirects to login_url when user is not logged in" do
      controller.stub!(:current_user).and_return nil
      request_to :get, '/admin/sites'
      response.should redirect_to(login_url)
    end

    # it "succeeds when user is logged in" do
    #   scenario :user_logged_in
    #   request_to :get, '/admin/sites'
    #   response.should be_success
    # end
  end
end