# FIXME implement these
require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class AdminUsersControllerTest < ActionController::TestCase
  tests Admin::UsersController
  
  with_common :a_site, :is_superuser
  
  test "should be an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |r|
      r.it_maps :get,     "users",          :action => 'index'
      r.it_maps :get,     "users/1",        :action => 'show',      :id => '1'
      r.it_maps :get,     "users/new",      :action => 'new'
      r.it_maps :post,    "users",          :action => 'create'
      r.it_maps :get,     "users/1/edit",   :action => 'edit',      :id => '1'
      r.it_maps :put,     "users/1",        :action => 'update',    :id => '1'
      r.it_maps :delete,  "users/1",        :action => 'destroy',   :id => '1'
    end
    
    with_options :path_prefix => '/admin/' do |r|
      r.it_maps :get,     "users",          :action => 'index'
      r.it_maps :get,     "users/1",        :action => 'show',      :id => '1'
      r.it_maps :get,     "users/new",      :action => 'new'
      r.it_maps :post,    "users",          :action => 'create'
      r.it_maps :get,     "users/1/edit",   :action => 'edit',      :id => '1'
      r.it_maps :put,     "users/1",        :action => 'update',    :id => '1'
      r.it_maps :delete,  "users/1",        :action => 'destroy',   :id => '1'
    end
  end

  describe "GET to :index, with a site" do
    action { get :index, default_params }
  
    it_guards_permissions :show, :user
    it_assigns :users
    it_renders_template :index
  end
  
  describe "GET to :index, without a site" do
    action { get :index }
  
    it_guards_permissions :show, :user
    it_assigns :users
    it_renders_template :index
  end

  describe "GET to :show" do
    action { get :show, user_params }
    
    it_guards_permissions :show, :user
    it_assigns :user
    it_renders_template :show
  end

  describe "GET to :new" do
    action { get :new, default_params }
    
    it_assigns :user => User
    it_renders_template :new
    it_guards_permissions :create, :user
  end

  describe "POST to :create" do
    action { post :create, valid_user_params }

    it_assigns :user => User
    it_guards_permissions :create, :user
    it_triggers_event :user_created
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { admin_site_user_path(@site, User.last) }
  end
  
  describe "POST to :create, with invalid params" do
    action { post :create, invalid_user_params }
  
    it_assigns :user => User
    it_guards_permissions :create, :user
    it_does_not_trigger_any_event
    it_assigns_flash_cookie :error => :not_nil
    it_renders_template 'new'
  end

  describe "GET to :edit" do
    action { get :edit, user_params }
    
    it_assigns :user
    it_renders_template :edit
    it_guards_permissions :update, :user
  end

  describe "PUT to :update" do
    action { put :update, valid_user_params.merge(:id => @user.id) }
    
    it_assigns :user
    it_guards_permissions :update, :user
    it_triggers_event :user_updated
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { admin_site_user_path(@site, @user) }
  end
  
  describe "PUT to :update, with invalid params" do
    action { put :update, invalid_user_params.merge(:id => @user.id) }
    
    it_assigns :user
    it_guards_permissions :update, :user
    it_does_not_trigger_any_event
    it_assigns_flash_cookie :error => :not_nil
    it_renders_template 'edit'
  end

  describe "DELETE to :destroy" do
    action { delete :destroy, user_params }
    
    it_assigns :user
    it_guards_permissions :destroy, :user
    it_assigns_flash_cookie :notice => :not_nil
    it_triggers_event :user_deleted
    it_redirects_to { admin_site_users_path(@site) }
  end
  
# FIXME implement tests for membership removing and RBAC system (integration or functional tests?)
#  describe "given valid user params (removing the user's site membership)" do
#    before :each do
#      @user.stub!(:is_site_member?).and_return false
#    end
#    it_redirects_to { @collection_path }
#    it_triggers_event :user_updated
#  end
  
# FIXME: how can destroy fail?
# describe "when destroy fails" do
#   before :each do @user.stub!(:destroy).and_return false end
#   it_renders_template :edit
#   it_assigns_flash_cookie :error => :not_nil
#   it_does_not_trigger_any_event
# end

# FIXME implement these:
#   it "disallows a non-superuser to add a superuser role"
#   it "disallows a non-admin to change any roles"
#   it "disallows a site-admin to directly add any memberships"
#   it "disallows a non-superuser to view another user's profile outside of a site scope"
  
  def default_params
    { :site_id => @site.id }
  end
  
  def user_params
    default_params.merge(:id => @user.id)
  end
  
  def valid_user_params
    default_params.merge(:user => { :first_name => 'John', :password => 'password', :email => 'John@test.org' })
  end
  
  def invalid_user_params
    default_params.merge(:user => { :first_name => 'John', :password => 'password', :email => '' })
  end
end