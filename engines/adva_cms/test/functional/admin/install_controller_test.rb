require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class AdminInstallControllerTest < ActionController::TestCase
  tests Admin::InstallController

  test "#normalize_params params[:site][:host] to the current request.host_with_port" do
    @controller.send(:normalize_install_params)
    @controller.params[:site][:host].should == @request.host_with_port
  end

  describe "routing" do
    with_options :controller => 'admin/install', :action => 'index' do |r|
      r.it_maps :get,  '/'
      r.it_maps :post, '/'
      r.it_maps :get,  '/admin/install'
      r.it_maps :post, '/admin/install'
      r.it_generates   '/admin/install'
    end
  end

  describe "GET to :index" do
    action { get :index }

    with :no_site, :no_user do
      it_assigns :site, :section, :user

      it_renders :template, :install do
        has_form_posting_to install_path do
          has_tag 'input[name=?]', 'site[name]'
          has_tag 'input[name=?]', 'section[title]'
          has_tag 'select[name=?]', 'section[type]'
        end
      end

      it "assigns the root section to the site" do
        assigns(:site).sections.first.should_not be_nil
      end
    end

    # with :a_site do
    #   # FIXME it_redirects_to :where?
    # end
  end

  describe "POST to :index" do
    action { post :index, @params }

    with :no_site, :no_user do
      with :valid_install_params do
        it_saves   :site, :section, :user
        it_changes 'Site.count' => 1, 'Section.count' => 1, 'User.count' => 1

        it "assigns the new Section to the new Site" do
          assigns(:section).reload.site.should_not be_nil
        end

        it "makes the new User a :superuser" do
          # Rbac::Role::Superuser.should === assigns(:user).reload.roles.first # FIXME
        end

        it "authenticates the current user as the new User" do
          @controller.current_user.should_not be_nil
        end

        it_renders :template, :confirmation do
          has_tag 'a[href=?]', admin_site_path(assigns(:site))
          # FIXME link to admin profile
        end
      end

      with :invalid_install_params do
        it_renders :template, 'admin/install'
        it_assigns_flash_cookie :error => :not_nil
        it_does_not_save :site
      end
    end
  end

  # # FIXME make this true. currently user validation in admin/install doesn't work
  #
  # test "POST :index with invalid user params" do
  #   post :index, :site => {:name => 'Site name'},
  #                :section => {:type => 'Page', :title => 'page title'}
  #
  #   it_renders :template 'admin/install'
  #   # it_assigns_flash_cookie :error => :not_nil
  #   it_does_not_save :user
  # end
end