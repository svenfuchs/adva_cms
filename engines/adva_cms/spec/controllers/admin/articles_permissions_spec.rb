require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Admin::ArticlesController, 'Permissions' do
  include SpecControllerHelper

  before :each do
    stub_scenario :roles

    @site = stub_model Site, :host => 'test.host'
    @blog = stub_model Blog, :id => 1, :site => @site
    @article = stub_model Article, :section => @blog

    Site.stub!(:find).and_return @site
    @site.sections.stub!(:find).and_return @blog
    @blog.articles.stub!(:find).and_return @article

    controller.stub!(:current_user).and_return @user
    @admin_role.context = @site
  end

  def should_grant_access(method, path)
    if method == :get
      request_to(method, path).should be_success
    else
      request_to(method, path).should redirect_to('http://test.host/pages/a-article')
    end
  end

  def should_show_insufficient_permissions(method, path)
    controller.expect_render(:template => 'shared/messages/insufficient_permissions')
    request_to(method, path)
  end

  def should_deny_access(method, path)
    request_to(method, path).should redirect_to('http://test.host/login')
  end

  { '/admin/sites/1/sections/1/articles/1/edit' => :get }.each do |path, method|

    describe "#{method.to_s.upcase} to #{path}" do
      describe "with :article/:update permissions set to :superuser" do
        before :each do
          permissions = {:'create article' => :superuser, :'update article' => :superuser, :'destroy article' => :superuser}
          @blog.stub!(:permissions).and_return permissions
        end

        it "grants access to an superuser" do
          @user.stub!(:roles).and_return [@superuser_role]
          should_grant_access(method, path)
        end

        it "shows an 'insufficient permissions' message to a non-superuser" do
          @user.stub!(:roles).and_return [@admin_role]
          should_show_insufficient_permissions(method, path)
        end
      end

      describe "with :article/:update permissions set to :admin" do
        before :each do
          permissions = {:'create article' => :admin, :'update article' => :admin, :'destroy article' => :admin}
          @blog.stub!(:permissions).and_return permissions
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

      # describe "with :article/:update permissions set to :moderator" do
      #   before :each do
      #     @user.stub!(:roles).and_return []
      #     Rbac::Context.stub!(:permissions).and_return :"update article" => :moderator
      #   end
      #
      #   it "grants access to a moderator" do
      #     @user.stub!(:roles).and_return [@moderator_role]
      #     should_grant_access(method, path)
      #   end
      #
      #   it "denies access to a non-moderator" do
      #     @user.stub!(:roles).and_return []
      #     should_deny_access(method, path)
      #   end
      # end
    end
  end
end
