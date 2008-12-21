require File.dirname(__FILE__) + "/../../test_helper"

# TODO

With.aspects << :access_control

class AdminThemeFilesControllerTest < ActionController::TestCase
  tests Admin::ThemeFilesController

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
    { :site_id => @site.id, :theme_id => @theme.id }
  end
   
  test "is an Admin::BaseController" do
    Admin::BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end
   
  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/themes/theme-1/', :site_id => "1", :theme_id => 'theme-1' do |r|
      r.it_maps :get,    "files",                        :action => 'index'
      r.it_maps :get,    "files/template-html-erb",      :action => 'show',    :id => 'template-html-erb'
      r.it_maps :get,    "files/new",                    :action => 'new'
      r.it_maps :post,   "files",                        :action => 'create'
      r.it_maps :get,    "files/template-html-erb/edit", :action => 'edit',    :id => 'template-html-erb'
      r.it_maps :put,    "files/template-html-erb",      :action => 'update',  :id => 'template-html-erb'
      r.it_maps :delete, "files/template-html-erb",      :action => 'destroy', :id => 'template-html-erb'
    end
  end

  describe "GET to :show" do
    action { get :show, default_params.merge(:id => @file.id) }

    with :a_theme_template do
      it_guards_permissions :update, :theme
      
      with :access_granted do
        it_assigns :theme, :file
        it_renders_template :show
      end
    end
  end

  describe "GET to :new" do
    action { get :new, default_params }
    
    with :a_theme do
      it_guards_permissions :update, :theme
      
      with :access_granted do
        it_assigns :theme
        it_renders_template :new
      end
    end
  end
  
  describe "POST to :create" do
    action { post :create, default_params.merge(@params) }
    
    with :a_theme do
      with :valid_theme_template_params do
        it_guards_permissions :update, :theme

        with :access_granted do
          it_assigns :theme, :file
          it_redirects_to { admin_theme_file_path(@site, @theme.id, assigns(:file).id) }
          it_assigns_flash_cookie :notice => :not_nil
  
          it "creates the theme template file" do
            File.exists?(assigns(:file).fullpath).should == true
          end
  
          expect "expires page cache for the current site" do
            mock(@controller).expire_site_page_cache
          end
        end
      end
    
      # FIXME
      # never gets here because the exception is not caught:
      # "Can't build file invalid because it seems to be neither a valid asset nor valid template path."
      # with :invalid_theme_template_params do
      #   it_renders_template :new
      #   it_assigns_flash_cookie :error => :not_nil
      # end
    end
  end
  
  describe "PUT to :update" do
    action { put :update, default_params.merge(@params).merge(:id => @file.id) }
    
    with :a_theme_template do
      with :valid_theme_template_params do
        it_guards_permissions :update, :theme
        
        with :access_granted do
          before { @params[:file][:data] = 'changed' }
          
          it_assigns :theme, :file
          it_redirects_to { admin_theme_file_path(@site, @theme.id, assigns(:file).id) }
          it_assigns_flash_cookie :notice => :not_nil
  
          it "updates the theme with the theme params" do
            @theme.files.find(@file.id).data.should =~ /changed/
          end
        end
      end
      
      # FIXME
      # never gets here because the exception is not caught: invalid filename "invalid"
      # with :invalid_theme_template_params do
      #   it_renders_template :show
      #   it_assigns_flash_cookie :error => :not_nil
      # end
    end
  end
  
  describe "DELETE to :destroy" do
    action { delete :destroy, default_params.merge(:id => @file.id) }

    with :a_theme_template do
      it_guards_permissions :update, :theme
      
      with :access_granted do
        it_assigns :theme, :file
        it_redirects_to { admin_theme_path(@site, @theme.id) }
        it_assigns_flash_cookie :notice => :not_nil
        
        it "destroys the theme template file" do
          File.exists?(@file.fullpath).should == false
        end
  
        expect "expires page cache for the current site" do
          mock(@controller).expire_site_page_cache
        end
      end
    end
  end
end

