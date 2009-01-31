# FIXME implement these

# require File.dirname(__FILE__) + "/../../spec_helper"
#
# describe Admin::UsersController do
#   include SpecControllerHelper
#
#   it "should be an Admin::BaseController" do
#     controller.should be_kind_of(Admin::BaseController)
#   end
#
#   ['', 'sites/1/'].each do |scope|
#     describe "with scope #{scope.inspect}" do
#
#       before :each do
#         stub_scenario :site_with_a_user
#         set_resource_paths :user, "/admin/#{scope}"
#
#         @controller.stub! :require_authentication
#         @controller.stub! :authorize_access # TODO ???
#         @controller.stub!(:has_permission?).and_return true
#       end
#
#       describe "routing" do
#         options = {:path_prefix => "/admin/#{scope}"}
#         options[:site_id] = "1" unless scope.blank?
#
#         with_options options do |route|
#           route.it_maps :get, "users", :index
#           route.it_maps :get, "users/1", :show, :id => '1'
#           route.it_maps :get, "users/new", :new
#           route.it_maps :post, "users", :create
#           route.it_maps :get, "users/1/edit", :edit, :id => '1'
#           route.it_maps :put, "users/1", :update, :id => '1'
#           route.it_maps :delete, "users/1", :destroy, :id => '1'
#         end
#       end
#
#       describe "GET to :index" do
#         act! { request_to :get, @collection_path }
#         # TODO depending on scope superuser or admin should be required
#         # it_guards_permissions :show, :user # deactivated all :show permissions in the backend
#         it_assigns :users
#         it_renders_template :index
#
#         if scope.blank?
#           it "fetches users from User.admins_and_superusers" do
#             User.should_receive(:admins_and_superusers).and_return @users
#             act!
#           end
#         else
#           it "fetches users from @site.users_and_superusers" do
#             @site.should_receive(:users_and_superusers).and_return @users
#             act!
#           end
#         end
#       end
#
#       describe "GET to :show" do
#         act! { request_to :get, @member_path }
#         it_assigns :user
#         it_renders_template :show
#       end
#
#       describe "GET to :new" do
#         act! { request_to :get, @new_member_path }
#         it_assigns :user
#         it_renders_template :new
#         it_guards_permissions :create, :user
#
#         it "instantiates a new user" do
#           User.should_receive(:new).and_return @user
#           act!
#         end
#       end
#
#       describe "POST to :create" do
#         before :each do
#           @user.stub!(:state_changes).and_return [:created]
#         end
#
#         act! { request_to :post, @collection_path }
#         it_assigns :user
#         it_guards_permissions :create, :user
#
#         if scope.blank?
#           it "instantiates a new user from User" do
#             User.should_receive(:new).and_return @user
#             act!
#           end
#         else
#           it "instantiates a new user from site.users" do
#             @site.users.should_receive(:build).and_return @user
#             act!
#           end
#         end
#
#         describe "given valid user params" do
#           it_redirects_to { @member_path }
#           it_assigns_flash_cookie :notice => :not_nil
#           it_triggers_event :user_created
#         end
#
#         describe "given invalid user params" do
#           before :each do @user.stub!(:update_attributes).and_return false end
#           it_renders_template :new
#           it_assigns_flash_cookie :error => :not_nil
#           it_does_not_trigger_any_event
#         end
#       end
#
#       describe "GET to :edit" do
#         act! { request_to :get, @edit_member_path }
#         it_assigns :user
#         it_renders_template :edit
#         it_guards_permissions :update, :user
#
#         it "fetches a user from User" do
#           User.should_receive(:find).and_return @user
#           act!
#         end
#       end
#
#       describe "PUT to :update" do
#         before :each do
#           @user.stub!(:state_changes).and_return [:updated]
#         end
#
#         act! { request_to :put, @member_path }
#         it_assigns :user
#         it_guards_permissions :update, :user
#
#         it "fetches a user from User" do
#           User.should_receive(:find).and_return @user
#           act!
#         end
#
#         it "updates the user with the user params" do
#           @user.should_receive(:update_attributes).and_return true
#           act!
#         end
#
#         describe "given valid user params (not removing the user's site membership)" do
#           it_redirects_to { @member_path }
#           it_assigns_flash_cookie :notice => :not_nil
#         end
#
#         describe "given valid user params (removing the user's site membership)" do
#           before :each do
#             @user.stub!(:is_site_member?).and_return false
#           end
#           it_redirects_to { @collection_path }
#           it_triggers_event :user_updated
#         end
#
#         describe "given invalid user params" do
#           before :each do @user.stub!(:update_attributes).and_return false end
#           it_renders_template :edit
#           it_assigns_flash_cookie :error => :not_nil
#           it_does_not_trigger_any_event
#         end
#       end
#
#       describe "DELETE to :destroy" do
#         before :each do
#           @user.stub!(:state_changes).and_return [:deleted]
#         end
#
#         act! { request_to :delete, @member_path }
#         it_assigns :user
#         it_guards_permissions :destroy, :user
#
#         it "fetches a user from User" do
#           User.should_receive(:find).and_return @user
#           act!
#         end
#
#         it "should try to destroy the user" do
#           @user.should_receive :destroy
#           act!
#         end
#
#         describe "when destroy succeeds" do
#           it_redirects_to { @collection_path }
#           it_assigns_flash_cookie :notice => :not_nil
#           it_triggers_event :user_deleted
#         end
#
#         describe "when destroy fails" do
#           before :each do @user.stub!(:destroy).and_return false end
#           it_renders_template :edit
#           it_assigns_flash_cookie :error => :not_nil
#           it_does_not_trigger_any_event
#         end
#       end
#     end
#   end
#
#   it "disallows a non-superuser to add a superuser role"
#   it "disallows a non-admin to change any roles"
#   it "disallows a site-admin to directly add any memberships"
#   it "disallows a non-superuser to view another user's profile outside of a site scope"
# end