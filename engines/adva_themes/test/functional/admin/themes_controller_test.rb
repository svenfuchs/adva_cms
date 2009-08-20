require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# With.aspects << :access_control

class AdminThemesControllerTest < ActionController::TestCase
  include ThemeTestHelper
  tests Admin::ThemesController

  with_common :a_site, :a_theme, :is_superuser

  def default_params
    { :site_id => @site.id }
  end

  view :form do
    has_tag 'input[name=?]', 'theme[name]'
    has_tag 'input[name=?]', 'theme[author]'
    has_tag 'input[name=?]', 'theme[homepage]'
    has_tag 'input[name=?]', 'theme[version]'
    has_tag 'textarea[name=?]', 'theme[summary]'
  end

  test "is an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |r|
      r.it_maps :get,    "themes",            :action => 'index'
      r.it_maps :get,    "themes/1",          :action => 'show',    :id => '1'
      r.it_maps :get,    "themes/new",        :action => 'new'
      r.it_maps :post,   "themes",            :action => 'create'
      r.it_maps :get,    "themes/1/edit",     :action => 'edit',    :id => '1'
      r.it_maps :put,    "themes/1",          :action => 'update',  :id => '1'
      r.it_maps :delete, "themes/1",          :action => 'destroy', :id => '1'

      r.it_maps :post,   "themes/selected",   :action => 'select'
      r.it_maps :delete, "themes/selected/1", :action => 'unselect', :id => '1'
      r.it_maps :get,    "themes/import",     :action => 'import'
      r.it_maps :post,   "themes/import",     :action => 'import'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params }

    it_guards_permissions :manage, :theme

    with :access_granted do
      it_assigns :themes
      it_renders :template, :index do
        has_tag 'ul[id=theme_list]'
      end
    end
  end

  describe "GET to :new" do
    action { get :new, default_params }

    it_guards_permissions :manage, :theme

    with :access_granted do
      it_assigns :theme => :not_nil
      it_renders :template, :new do
        has_form_posting_to admin_themes_path do
          shows :form
        end
      end
    end
  end

  describe "POST to :create" do
    action { post :create, default_params.merge(@params) }

    with :valid_theme_params do
      it_guards_permissions :create, :theme

      with :access_granted do
        it_saves :theme
        it_assigns :site, :theme => :not_nil
        it_redirects_to { admin_themes_url }
        it_assigns_flash_cookie :notice => :not_nil

        it "associates the new Theme to the current site" do
          assigns(:theme).site.should == @site
        end
      end
    end

    with :invalid_theme_params do
      it_renders :template, :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @theme.id) }

    it_guards_permissions :manage, :theme

    with :access_granted do
      it_assigns :theme
      it_renders :template, :edit do
        has_form_putting_to admin_theme_path(@site, @theme.id) do
          shows :form
        end
      end
    end
  end

  describe "PUT to :update" do
    action { put :update, default_params.merge(@params).merge(:id => @theme.id) }

    with :valid_theme_params do
      it_guards_permissions :update, :theme

      with :access_granted do
        before { @params[:theme][:author] = 'changed' }

        it_saves :theme
        it_assigns :site, :theme => :not_nil
        it_redirects_to { edit_admin_theme_url(@site, assigns(:theme).id) }
        it_assigns_flash_cookie :notice => :not_nil

        it "updates the theme with the theme params" do
          @theme.reload.author.should =~ /changed/
        end
      end
    end

    with :invalid_theme_params do
      it_renders :template, :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "DELETE to :destroy" do
    action { delete :destroy, default_params.merge(:id => @theme.id) }

    it_guards_permissions :destroy, :theme

    with :access_granted do
      before { FileUtils.mkdir_p(@theme.path) unless ::File.exists?(@theme.path) }

      it_assigns :theme
      it_redirects_to { admin_themes_url }
      it_assigns_flash_cookie :notice => :not_nil

      it "deletes the theme directory" do
        @theme.path.should_not be_directory
      end

      expect "expires page cache for the current site" do
        mock(@controller).expire_site_page_cache
      end
    end
  end

  describe "POST to :select" do
    action { post :select, default_params.merge(:id => @theme.id) }

    it_guards_permissions :update, :theme

    with :access_granted do
      it_redirects_to { admin_themes_url }

      it "activates the theme" do
        @theme.reload.active?.should be_true
      end

      expect "expires page cache for the current site" do
        mock(@controller).expire_site_page_cache
      end
    end
  end

  describe "DELETE to :unselect" do
    action { delete :unselect, default_params.merge(:id => @theme.id) }

    it_guards_permissions :update, :theme

    with :access_granted do
      it_redirects_to { admin_themes_url }

      it "deactivates the theme" do
        @theme.reload.active?.should be_false
      end

      expect "expires page cache for the current site" do
        mock(@controller).expire_site_page_cache
      end
    end
  end

  describe "GET to :import" do
    action { get :import, default_params }

    it_guards_permissions :create, :theme

    with :access_granted do
      it_renders :template, :import
    end
  end

  describe "POST to :import" do
    action { post :import, @params }

    it_guards_permissions :create, :theme

    with :access_granted do
      with "valid uploaded theme zip file" do
        before { @params = default_params.merge(:theme => { :file => theme_fixture }) }
        it_redirects_to { admin_themes_url }
        it_assigns_flash_cookie :notice => :not_nil
      end

      with "no theme zip file uploaded" do
        before { @params = default_params.merge(:theme => { :file => nil }) }
        it_renders :template, :import
        it_assigns_flash_cookie :error => :not_nil
      end
    end
  end

  describe "GET to :export" do
    action { get :export, default_params.merge(:id => @theme.id) }

    it_guards_permissions :manage, :theme

    with :access_granted do
      # send file matcher?
      # it_sends_file ...
      # deletes temp file?
    end
  end

  # # FIXME specify with valid params
  # describe "POST to :import, without a file" do
  #   action { post :import, default_params.merge(:theme => {:file => ''}) }
  #
  #   it_guards_permissions :create, :theme
  #
  #   with :access_granted do
  #     it_assigns_flash_cookie :error => :not_nil
  #   end
  # end
end
