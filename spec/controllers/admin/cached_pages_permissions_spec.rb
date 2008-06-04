require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Admin::CachedPagesController, 'Permissions' do
  include SpecControllerHelper

  before :each do
    scenario :site, :cached_page, :cached_page
  
    @user = User.new
    @user.stub!(:roles).and_return []
          
    @site = Site.new(:host => 'test.host')
    Site.stub!(:find).and_return @site

    @cached_page = CachedPage.new

    controller.stub!(:current_user).and_return @user      
  
    @superuser_role = Role.new :name => 'superuser', :user => @user, :object => nil
    @admin_role = Role.new :name => 'admin', :user => @user, :object => @site
  end
  
  def should_grant_access(method, path)
    if method == :get
      request_to(method, path).should be_success
    else
      request_to(method, path).should redirect_to('http://test.host/pages/a-article')
    end
  end
  
  def should_deny_access(method, path)
    lambda{ request_to(method, path) }.should raise_error(ActionController::RoleRequired) # TODO
  end
  
  { '/admin/sites/1/cached_pages' => :get }.each do |path, method|
  
    describe "#{method.to_s.upcase} to #{path}" do
      describe "with :manage_site permissions set to :superuser" do
        before :each do 
          @site.stub!(:required_roles).and_return :manage_site => :superuser
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

      describe "with :manage_site permissions set to :admin" do
        before :each do 
          @site.stub!(:required_roles).and_return :manage_site => :admin
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
      
      describe "with :manage_site permissions set to :user" do
        before :each do 
          @user.stub!(:roles).and_return []
          @site.stub!(:required_roles).and_return :manage_site => :user
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
