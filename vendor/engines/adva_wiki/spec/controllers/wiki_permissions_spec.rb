require File.dirname(__FILE__) + '/../spec_helper.rb'

describe WikiController, 'Permissions' do
  include SpecControllerHelper
  before :each do
    scenario :wiki_with_wikipages, :roles

    @site = stub_model Site, :host => 'test.host'
    @wiki = stub_model Wiki, :id => 1, :site => @site, :path => 'wiki'
    @wikipage = stub_model Wikipage, :section => @wiki
    
    @wiki.wikipages.stub!(:create).and_return @wikipage
    @wiki.wikipages.stub!(:find).and_return @wikipage
    @wiki.wikipages.stub!(:find_or_initialize_by_permalink).and_return @wikipage

    Site.stub!(:find).and_return @site
    @site.stub!(:sections).and_return [@wiki]
    @site.sections.stub!(:find).and_return @wiki
    @site.sections.stub!(:paths).and_return ['wiki']
    @site.sections.stub!(:root).and_return @wiki

    controller.stub!(:trigger_events)
    controller.stub!(:current_user).and_return @user
    controller.stub!(:wikipage_path).and_return('http://test.host/pages/a-wikipage')
    @admin_role.context = @site

    Site.stub!(:find_by_host).and_return @site
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

  { # '/wikis/1/pages/home' => :get,
    '/wikis/1/pages/home/edit' => :get,
    '/wikis/1/pages' => :post }.each do |path, method|

    describe "#{method.to_s.upcase} to #{path}" do
      describe "with wikipage permissions set to :admin" do
        before :each do
          permissions = {:'create wikipage' => :admin, :'update wikipage' => :admin, :'destroy wikipage' => :admin}
          @wiki.stub!(:permissions).and_return permissions
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

      describe "with wikipage permissions set to :user" do
        before :each do
          @user.stub!(:roles).and_return []
          permissions = {:'create wikipage' => :user, :'update wikipage' => :user, :'destroy wikipage' => :user}
          @wiki.stub!(:permissions).and_return permissions
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

      describe "with wikipage permissions set to :anonymous" do
        before :each do
          @user.stub!(:roles).and_return []
          @wiki.stub!(:permissions).and_return :wikipage => { :show => :anonymous, :create => :anonymous, :update => :anonymous }
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
