require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# TODO

# With.aspects << :access_control

class AdminThemeFilesControllerTest < ThemeControllerTestCase
  tests Admin::ThemeFilesController

  def setup
    super
    stub_paperclip_post_processing!
  end

  with_common :a_site, :a_theme, :is_superuser, :a_theme_template

  def default_params
    { :site_id => @site.id, :theme_id => @theme.id }
  end

  view :form do
    has_tag 'input[name=?]', 'file[base_path]'
    has_tag 'textarea[name=?]', 'file[data]'
    # FIXME
    # renders a file data textarea when the file has text content
    # does not render a file data textarea when the file does not have text content
    # response.should_not have_tag('textarea[name=?]', 'file[data]')
  end

  view :files_list do
    ['Templates', 'Assets'].each {|type| has_tag 'h3', type }
    has_tag 'a[href=?]', admin_theme_file_path(@site, @theme.id, @file.id)
  end

  test "is an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/themes/1/', :site_id => "1", :theme_id => '1' do |r|
      r.it_maps :get,    "files",                        :action => 'index'
      r.it_maps :get,    "files/template-html-erb",      :action => 'show',    :id => 'template-html-erb'
      r.it_maps :get,    "files/new",                    :action => 'new'
      r.it_maps :post,   "files",                        :action => 'create'
      r.it_maps :get,    "files/template-html-erb/edit", :action => 'edit',    :id => 'template-html-erb'
      r.it_maps :put,    "files/template-html-erb",      :action => 'update',  :id => 'template-html-erb'
      r.it_maps :delete, "files/template-html-erb",      :action => 'destroy', :id => 'template-html-erb'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params }

    it_guards_permissions :update, :theme

    with :access_granted do
      it_assigns :theme
      it_renders :template, :index do
        [:templates, :stylesheets, :javascripts, :images, :others].each do |file_type|
          has_tag "table[id=theme_#{file_type}][class~=list]"
        end
      end
    end
  end

  describe "GET to :show" do
    action { get :show, default_params.merge(:id => @file.id) }

    it_guards_permissions :update, :theme

    with :access_granted do
      it_assigns :theme, :file
      it_renders :template, :show do
        has_form_putting_to admin_theme_file_path(@site, @theme, @file.id) do
          shows :form
        end
      end
    end
  end

  describe "GET to :new" do
    action { get :new, default_params }

    it_guards_permissions :update, :theme

    with :access_granted do
      it_assigns :theme
      it_renders :template, :new do
        has_form_posting_to admin_theme_files_path(@site, @theme) do
          shows :form
        end
      end
    end
  end

  describe "POST to :create" do
    action { post :create, default_params.merge(@params) }

    with :valid_theme_template_params do
      it_guards_permissions :update, :theme

      with :access_granted do
        it_assigns :theme, :file => :not_nil
        it_redirects_to { admin_theme_file_url(@site, @theme, assigns(:file).id) }
        it_assigns_flash_cookie :notice => :not_nil

        it "creates the theme template file" do
          @theme.templates.find_by_name(@params[:file][:name]).should_not be_nil
        end

        expect "expires page cache for the current site" do
          mock(@controller).expire_site_page_cache
        end
      end
    end

    with :invalid_theme_template_params do
      it_renders :template, :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "GET to :import" do
    action { get :import, default_params }

    it_guards_permissions :update, :theme

    with :access_granted do
      it_assigns :theme
      it_renders :template, :import do
        has_form_posting_to upload_admin_theme_files_path(@site, @theme) do
          has_tag 'input[name=?][type=?]', 'files[][data]', 'file'
        end
      end
    end
  end

  describe "POST to :upload" do
    action { post :upload, default_params.merge(@params) }

    with :valid_theme_upload_params do
      it_guards_permissions :update, :theme

      with :access_granted do
        it_assigns :theme, :files => :not_nil
        it_redirects_to { admin_theme_files_url(@site, @theme) }
        it_assigns_flash_cookie :notice => :not_nil

        it "creates the theme image file" do
          @theme.files.find_by_name('rails.png').should_not be_nil
        end

        expect "expires page cache for the current site" do
          mock(@controller).expire_site_page_cache
        end
      end
    end

    with :invalid_theme_upload_params do
      it_renders :template, :import
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "PUT to :update" do
    action { put :update, default_params.merge(@params).merge(:id => @file.id) }

    with :valid_theme_template_params do
      it_guards_permissions :update, :theme

      with :access_granted do
        before { @params[:file][:data] = 'changed' }

        it_assigns :theme, :file => :not_nil
        it_redirects_to { admin_theme_file_url(@site, @theme.id, assigns(:file).id) }
        it_assigns_flash_cookie :notice => :not_nil

        it "updates the theme with the theme params" do
          @theme.files.find(@file.id).data.should =~ /changed/
        end
      end
    end

    with :invalid_theme_template_params do
      it_renders :template, :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "DELETE to :destroy" do
    action { delete :destroy, default_params.merge(:id => @file.id) }

    it_guards_permissions :update, :theme

    with :access_granted do
      it_destroys :file
      it_assigns :theme, :file => :not_nil
      it_redirects_to { admin_theme_files_url(@site, @theme.id) }
      it_assigns_flash_cookie :notice => :not_nil

      expect "expires page cache for the current site" do
        mock(@controller).expire_site_page_cache
      end
    end
  end
end