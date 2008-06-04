require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Admin::CategoriesController, 'Permissions' do
  include SpecControllerHelper

  before :each do
    scenario :site, :section, :section, :category
  
    @user = User.new
    @user.stub!(:roles).and_return []
          
    @site = Site.new(:host => 'test.host')
    @section = Section.new
    @section.stub!(:id).and_return 1
    @section.stub!(:site).and_return @site

    @category = Category.new
    @category.stub!(:section).and_return @section
    
    @site.sections.stub!(:find).and_return @section
    Site.stub!(:find).and_return @site
    @section.categories.stub!(:find).and_return @category
    @section.categories.stub!(:paginate).and_return [@categories]

    controller.stub!(:current_user).and_return @user      
  
    @superuser_role = Role.new :name => 'superuser', :user => @user, :object => nil
    @admin_role = Role.new :name => 'admin', :user => @user, :object => @site
  end
  
  def should_grant_access(method, path)
    if method == :get
      request_to(method, path).should be_success
    else
      request_to(method, path).should redirect_to('http://test.host/pages/a-category')
    end
  end
  
  def should_deny_access(method, path)
    lambda{ request_to(method, path) }.should raise_error(ActionController::RoleRequired) # TODO
  end
  
  { '/admin/sites/1/sections/1/categories' => :get,
    '/admin/sites/1/sections/1/categories/1/edit' => :get }.each do |path, method|
  
    describe "#{method.to_s.upcase} to #{path}" do
      describe "with :manage_categories permissions set to :superuser" do
        before :each do 
          @section.stub!(:required_roles).and_return :manage_categories => :superuser
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

      describe "with :manage_categories permissions set to :admin" do
        before :each do 
          @section.stub!(:required_roles).and_return :manage_categories => :admin
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
      
      describe "with :manage_categories permissions set to :user" do
        before :each do 
          @user.stub!(:roles).and_return []
          @section.stub!(:required_roles).and_return :manage_categories => :user
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
