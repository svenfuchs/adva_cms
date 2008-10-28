require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Admin::SectionsController, 'Permissions' do
  include SpecControllerHelper

  before :each do
    scenario :roles

    @account = stub_model Account
    @site = stub_model Site, :host => 'test.host', :account => @account
    @section = stub_model Section, :id => 1, :site => @site, :destroy => true

    Site.stub!(:find).and_return @site
    @site.sections.stub!(:find).and_return @section

    controller.stub!(:current_user).and_return @user
    @admin_role.context = @site

    controller.stub!(:admin_section_path).and_return '/redirect_here'
    controller.stub!(:new_admin_section_path).and_return '/redirect_here'
  end

  def should_grant_access(method, path)
    if method == :get
      request_to(method, path).should be_success
    else
      request_to(method, path).should redirect_to('http://test.host/redirect_here')
    end
  end

  def should_show_insufficient_permissions(method, path)
    controller.expect_render(:template => 'shared/messages/insufficient_permissions')
    request_to(method, path)
  end

  def should_deny_access(method, path)
    request_to(method, path).should redirect_to('http://test.host/login')
  end

  { '/admin/sites/1/sections/1' => :get,
    '/admin/sites/1/sections/1/edit' => :get,
    '/admin/sites/1/sections/1' => :delete }.each do |path, method|

    describe "#{method.to_s.upcase} to #{path}" do
      describe "with sections permissions set to :superuser" do
        before :each do
          permissions = {:'create section' => :superuser, :'update section' => :superuser, :'destroy section' => :superuser}
          @site.stub!(:permissions).and_return permissions
          
        end

        it "grants access to an superuser" do
          @user.stub!(:roles).and_return [@superuser_role]
          should_grant_access(method, path)
        end

        it "denies access to an admin" do
          @user.stub!(:roles).and_return [@admin_role]
          should_show_insufficient_permissions(method, path)
        end
      end

      describe "with sections permissions set to :admin" do
        before :each do
          permissions = {:'create section' => :admin, :'update section' => :admin, :'destroy section' => :admin}
          @site.stub!(:permissions).and_return permissions
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

      # describe "with sections permissions set to :user" do
      #   before :each do
      #     @user.stub!(:roles).and_return []
      #     @site.stub!(:permissions).and_return :section => { :show => :user, :update => :user, :destroy => :user }
      #   end
      #
      #   it "grants access to a user" do
      #     @user.stub!(:registered?).and_return true
      #     should_grant_access(method, path)
      #   end
      #
      #   it "denies access to a non-user" do
      #     @user.stub!(:registered?).and_return false
      #     should_deny_access(method, path)
      #   end
      # end
    end
  end
end
