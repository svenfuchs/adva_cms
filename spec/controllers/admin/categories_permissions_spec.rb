require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Admin::CategoriesController, 'Permissions' do
  include SpecControllerHelper

  before :each do
    scenario :roles

    @site = stub_model Site, :host => 'test.host'
    @section = stub_model Section, :id => 1, :site => @site
    @category = stub_model Category, :section => @section

    Site.stub!(:find).and_return @site
    @site.sections.stub!(:find).and_return @section
    @section.categories.stub!(:find).and_return @category
    @section.categories.stub!(:paginate).and_return [@categories]

    controller.stub!(:current_user).and_return @user
    @admin_role.context = @site
  end

  def should_grant_access(method, path)
    if method == :get
      request_to(method, path).should be_success
    else
      request_to(method, path).should redirect_to('http://test.host/pages/a-category')
    end
  end

  def should_show_insufficient_permissions(method, path)
    controller.expect_render(:template => 'shared/messages/insufficient_permissions')
    request_to(method, path)
  end

  def should_deny_access(method, path)
    request_to(method, path).should redirect_to('http://test.host/login')
  end

  { # '/admin/sites/1/sections/1/categories' => :get, # deactivated all :show permissions in the backend
    '/admin/sites/1/sections/1/categories/1/edit' => :get }.each do |path, method|

    describe "#{method.to_s.upcase} to #{path}" do
      describe "with category permissions set to :superuser" do
        before :each do
          @section.stub!(:permissions).and_return :category => { :show => :superuser, :update => :superuser }
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

      describe "with category permissions set to :admin" do
        before :each do
          @section.stub!(:permissions).and_return :category => { :show => :admin, :update => :admin }
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

      # describe "with category permissions set to :user" do
      #   before :each do
      #     @user.stub!(:roles).and_return []
      #     @section.stub!(:permissions).and_return :category => { :show => :user, :update => :user }
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
