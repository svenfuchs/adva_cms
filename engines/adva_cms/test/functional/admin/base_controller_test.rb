# FIXME spec common behaviour on BaseController

# require File.dirname(__FILE__) + "/../../spec_helper"
#
# describe Admin::SitesController do
#   include SpecControllerHelper
#
#   before :each do
#     @user = User.new
#     stub_scenario :empty_site
#     controller.stub!(:guard_permission)
#     controller.stub!(:current_user).and_return(@user)
#   end
#
#   describe "#require_authentication" do
#     it "redirects to login_url when user is not logged in" do
#       request_to :get, '/admin/sites'
#       response.should redirect_to(login_url(:return_to => request.url))
#     end
#
#     # TODO what's this good for at all?
#     # it "updates current_role_context" do
#     #   controller.should_receive(:update_role_context!).with({"action"=>"index", "controller"=>"admin/sites"})
#     #   request_to :get, '/admin/sites'
#     #   response.should redirect_to(login_url(:return_to => request.url))
#     # end
#
#     it "uses current_role_context for context of a role" do
#       @user.stub!(:has_role?).and_return(true)
#       controller.stub!(:update_role_context!)
#
#       controller.should_receive(:current_role_context)
#       controller.send :require_authentication
#     end
#   end
# end
#
# describe Admin::BaseController, "when the user is logged in" do
#   include SpecControllerHelper
#
#   before :each do
#     @user = mock_model(User)
#     stub_scenario :empty_site
#     stub_scenario :user_logged_in
#     controller.stub!(:current_user).and_return(@user)
#     controller.stub!(:update_role_context!)
#   end
#
#   describe "#require_authentication" do
#     it "succeeds for a superuser" do
#       @user.stub!(:roles).and_return([Rbac::Role.build(:superuser)])
#       controller.should_not_receive(:redirect_to_login)
#       controller.send(:require_authentication)
#     end
#
#     it "does not succeed for an admin" do
#       @user.stub!(:roles).and_return([Rbac::Role.build(:admin, :context => Site.new)])
#       controller.should_receive(:redirect_to_login)
#       controller.send(:require_authentication)
#     end
#
#     it "does not succeed for an anonymous user" do
#       @user.stub!(:anonymous?).and_return true
#       controller.should_receive(:redirect_to_login)
#       controller.send(:require_authentication)
#     end
#   end
# end
