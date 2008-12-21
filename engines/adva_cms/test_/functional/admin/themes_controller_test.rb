require File.dirname(__FILE__) + "/../../test_helper"

# With.aspects << :access_control

class AdminThemesControllerTest < ActionController::TestCase
  tests Admin::ThemesController

  def setup
    super
    login_as_superuser!
  end
  
  def teardown
    super
    theme_root = "#{RAILS_ROOT}/tmp/themes"
    FileUtils.rm_r theme_root if File.exists?(theme_root)
  end
  
  def default_params
    { :site_id => @site.id }
  end
   
  test "is an Admin::BaseController" do
    Admin::BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end
   
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |r|
      r.it_maps :get,    "themes",                  :action => 'index'
      r.it_maps :get,    "themes/theme-1",          :action => 'show',    :id => 'theme-1'
      r.it_maps :get,    "themes/new",              :action => 'new'
      r.it_maps :post,   "themes",                  :action => 'create'
      r.it_maps :get,    "themes/theme-1/edit",     :action => 'edit',    :id => 'theme-1'
      r.it_maps :put,    "themes/theme-1",          :action => 'update',  :id => 'theme-1'
      r.it_maps :delete, "themes/theme-1",          :action => 'destroy', :id => 'theme-1'

      r.it_maps :post,   "themes/selected",         :action => 'select'
      r.it_maps :delete, "themes/selected/theme-1", :action => 'unselect', :id => 'theme-1'
      r.it_maps :get,    "themes/import",           :action => 'import'
      r.it_maps :post,   "themes/import",           :action => 'import'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params }
    
    with :a_theme do
      it_guards_permissions :manage, :theme
      
      with :access_granted do
        it_assigns :themes
        it_renders_template :index
      end
    end
  end
  
  describe "GET to :show" do
    action { get :show, default_params.merge(:id => @theme.id) }
    
    with :a_theme do
      it_guards_permissions :manage, :theme
      
      with :access_granted do
        it_assigns :theme
        it_renders_template :show
      end
    end
  end
  
  describe "POST to :create" do
    action { post :create, default_params.merge(@params) }
    
    with :an_empty_site do
      with :valid_theme_params do
        it_guards_permissions :create, :theme

        with :access_granted do
          it_assigns :theme
          it_redirects_to { admin_themes_path }
          it_assigns_flash_cookie :notice => :not_nil
  
          it "creates the theme" do
            File.exists?(assigns(:theme).path).should == true
          end
        end
      end
    
      with :invalid_theme_params do
        it_renders_template :new
        it_assigns_flash_cookie :error => :not_nil
      end
    end
  end
  
  describe "PUT to :update" do
    action { put :update, default_params.merge(@params).merge(:id => @theme.id) }
    
    with :a_theme do
      with :valid_theme_params do
        it_guards_permissions :update, :theme
        
        with :access_granted do
          before { @params[:theme][:author] = 'changed' }
          
          it_assigns :theme
          it_redirects_to { admin_theme_path(@site, assigns(:theme).id) }
          it_assigns_flash_cookie :notice => :not_nil
  
          it "updates the theme with the theme params" do
            @site.themes.find('theme_1').author.should =~ /changed/
          end
        end
      end
      
      # FIXME does not fail
      # for some reason the id remains the same, but the name is empty
      # with :invalid_theme_params do
      #   it_renders_template :show
      #   it_assigns_flash_cookie :error => :not_nil
      # end
    end
  end
  
  describe "DELETE to :destroy" do
    action { delete :destroy, default_params.merge(:id => @theme.id) }

    with :a_theme do
      it_guards_permissions :destroy, :theme
      
      with :access_granted do
        it_assigns :theme
        it_redirects_to { admin_themes_path }
        it_assigns_flash_cookie :notice => :not_nil
        
        it "destroys the theme" do
          File.exists?(@theme.path).should == false
        end
  
        expect "expires page cache for the current site" do
          mock(@controller).expire_site_page_cache
        end
      end
    end
  end
  
  describe "POST to :select" do
    action { post :select, default_params.merge(:id => @theme.id) }
    
    with :a_theme do
      it_guards_permissions :update, :theme
      
      with :access_granted do
        it_redirects_to { admin_themes_path }
  
        it "adds the theme id to the site's theme_names" do
          @site.reload.theme_names.should include(@theme.id)
        end
  
        expect "expires page cache for the current site" do
          mock(@controller).expire_site_page_cache
        end
      end
    end
  end
  
  describe "DELETE to :unselect" do
    action { delete :unselect, default_params.merge(:id => @theme.id) }
    
    with :a_theme do
      it_guards_permissions :update, :theme
      
      with :access_granted do
        it_redirects_to { admin_themes_path }
  
        it "removes the theme id to the site's theme_names" do
          @site.reload.theme_names.should_not include(@theme.id)
        end
  
        expect "expires page cache for the current site" do
          mock(@controller).expire_site_page_cache
        end
      end
    end
  end
  
  describe "GET to :import" do
    action { get :import, default_params }

    with :an_empty_site do
      it_guards_permissions :create, :theme
    
      with :access_granted do
        it_renders_template :import
      end
    end
  end
  
  # FIXME specify with valid params
  describe "POST to :import, without a file" do
    action { post :import, default_params.merge(:theme => {:file => ''}) }
    
    with :an_empty_site do
      it_guards_permissions :create, :theme
    
      with :access_granted do
        it_assigns_flash_cookie :error => :not_nil
      end
    end
  end
end
