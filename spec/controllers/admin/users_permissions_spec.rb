require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Admin::UsersController, 'Permissions' do
  include SpecControllerHelper

  before :each do
    scenario :roles

    @site = stub_model Site, :host => 'test.host'
    @user.stub!(:destroy).and_return true
    
    Site.stub!(:find).and_return @site
    Site.stub!(:paginate_users_and_superusers).and_return [@user]
    User.stub!(:paginate).and_return [@user]
    User.stub!(:find).and_return @user
    
    controller.stub!(:current_user).and_return @user
    @admin_role.context = @site
    
    controller.stub!(:collection_path).and_return '/redirect_here'
    controller.stub!(:member_path).and_return '/redirect_here'
    controller.stub!(:new_member_path).and_return '/redirect_here'
    controller.stub!(:edit_member_path).and_return '/redirect_here'
  end
  
  def should_grant_access(method, path)
    if method == :get
      request_to(method, path).should be_success
    else
      request_to(method, path).should redirect_to('http://test.host/redirect_here')
    end
  end
  
  def should_deny_access(method, path)
    lambda{ request_to(method, path) }.should raise_error(ActionController::RoleRequired) # TODO
  end
  
  { '/admin/sites/1/users/1' => :get,
    '/admin/sites/1/users/1/edit' => :get,
    '/admin/sites/1/users/1' => :delete 
    }.each do |path, method|
  
    describe "#{method.to_s.upcase} to #{path}" do
      describe "with user permissions set to :superuser" do
        before :each do 
          @site.stub!(:permissions).and_return :user => { :show => :superuser, :update => :superuser, :destroy => :superuser }
        end
        
        it "grants access to an superuser" do
          @user.stub!(:roles).and_return [@superuser_role]
          should_grant_access(method, path)
        end
              
        it "denies access to a non-superuser" do
          @user.stub!(:roles).and_return [@admin_role]
          should_deny_access(method, path)
        end
      end
    
      describe "with user permissions set to :admin" do
        before :each do 
          @site.stub!(:permissions).and_return :user => { :show => :admin, :update => :admin, :destroy => :admin }
        end
        
        it "grants access to an admin" do
          @user.stub!(:roles).and_return [@admin_role]
          should_grant_access(method, path)
        end
      
        it "denies access to a non-admin" do
          @user.stub!(:roles).and_return []
          should_deny_access(method, path)
        end
      end 
      
      describe "with user permissions set to :user" do
        before :each do 
          @user.stub!(:roles).and_return []
          @site.stub!(:permissions).and_return :user => { :show => :user, :update => :user, :destroy => :user }
        end
        
        it "grants access to a user" do
          @user.stub!(:registered?).and_return true
          should_grant_access(method, path)
        end
      
        it "denies access to a non-user" do
          @user.stub!(:registered?).and_return false
          should_deny_access(method, path)
        end
      end
    end
  end
end
