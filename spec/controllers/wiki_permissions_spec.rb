require File.dirname(__FILE__) + '/../spec_helper.rb'

describe WikiController, 'Permissions' do
  include SpecControllerHelper
  before :each do
    scenario :site, :section, :wiki, :wikipage
  
    @user = User.new
    @user.stub!(:roles).and_return []
    
    @site = Site.new(:host => 'test.host')
    @wiki = Wiki.new
    @wiki.stub!(:id).and_return 1
    @wiki.stub!(:site).and_return @site
    @wiki.wikipages.stub!(:create).and_return @wikipage

    @wikipage = Wikipage.new
    @wikipage.stub!(:section).and_return @wiki
    
    @site.sections.stub!(:find).and_return @wiki
    @site.sections.stub!(:root).and_return @wiki
    Site.stub!(:find_or_initialize_by_host).and_return @site
    @wiki.wikipages.stub!(:find_or_initialize_by_permalink).and_return @wikipage
    
    controller.stub!(:current_user).and_return @user      
  
    @admin_role = Role.new :name => 'admin', :user => @user, :object => @site
  end
  
  def should_grant_access(method, path)
    if method == :get
      request_to(method, path).should be_success
    else
      request_to(method, path).should redirect_to('http://test.host/pages/a-wikipage')
    end
  end
  
  def should_deny_access(method, path)
    controller.should_receive :redirect_to_login
    request_to(method, path)
  end
  
  { '/wiki/pages/home' => :get, 
    '/wiki/pages/home/edit' => :get, 
    '/wiki/pages' => :post }.each do |path, method|
  
    describe "#{method.to_s.upcase} to #{path}" do
      describe "with :manage_wikipages permissions set to :admin" do
        before :each do 
          @wiki.stub!(:required_roles).and_return :manage_wikipages => :admin
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
      
      describe "with :manage_wikipages permissions set to :user" do
        before :each do 
          @user.stub!(:roles).and_return []
          @wiki.stub!(:required_roles).and_return :manage_wikipages => :user
        end
        
        it "grants access to an user" do
          @user.stub!(:registered?).and_return true
          should_grant_access(method, path)
        end
      
        it "denies access to a non-user" do
          @user.stub!(:registered?).and_return false
          should_deny_access(method, path)
        end
      end
      
      describe "with :manage_wikipages permissions set to :anonymous" do
        before :each do 
          @user.stub!(:roles).and_return []
          @wiki.stub!(:required_roles).and_return :manage_wikipages => :anonymous
        end
        
        it "grants access to an user" do
          @user.stub!(:registered?).and_return true
          should_grant_access(method, path)
        end
      
        it "denies access to a non-user" do
          should_grant_access(method, path)
        end
      end
    end
  end
end
