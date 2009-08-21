require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# With.aspects << :access_control

class AdminCategoriesControllerTest < ActionController::TestCase
  tests Admin::CategoriesController

  with_common :is_superuser, [:a_page, :a_blog], :a_category

  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end

  view :form do
    # FIXME ...
  end

  test "is an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |r|
      r.it_maps :get,    "categories",        :action => 'index'
      r.it_maps :get,    "categories/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "categories/new",    :action => 'new'
      r.it_maps :post,   "categories",        :action => 'create'
      r.it_maps :get,    "categories/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "categories/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "categories/1",      :action => 'destroy', :id => '1'
    end
  end

  describe "de routing" do
    with_options :path_prefix => '/de/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |r|
      r.it_maps :put,    "categories/1",      :action => 'update',  :id => '1', :locale => 'de'
    end
  end

  test "category url in :de locale" do
    site = Site.first
    section = Section.first
    category = Category.first
    assert_equal "/admin/sites/#{site.id}/sections/#{section.id}/categories/#{category.id}", admin_category_path(site, section, category)
    I18n.locale = :de
    assert_equal "/de/admin/sites/#{site.id}/sections/#{section.id}/categories/#{category.id}", admin_category_path(site, section, category)
    I18n.locale = :en
  end

  describe "GET to :index" do
    action { get :index, default_params }

    it_guards_permissions :show, :category

    with :access_granted do
      it_assigns :site, :section
      it_renders :template, :index do
        has_tag 'table[id=categories] tr td a[href=?]', edit_admin_category_path(@site, @section, @category)
      end
    end
  end

  describe "GET to :new" do
    action { get :new, default_params }

    it_guards_permissions :create, :category

    with :access_granted do
      it_assigns :site, :section
      it_renders :template, :new do
        has_form_posting_to admin_categories_path(@site, @section) do
          shows :form
        end
      end
    end
  end

  describe "POST to :create" do
    action do
      Category.with_observers :category_sweeper do
        post :create, default_params.merge(@params)
      end
    end

    with :valid_category_params do
      it_guards_permissions :create, :category

      with :access_granted do
        it_assigns :category => :not_nil
        it_redirects_to { admin_categories_url }
        it_assigns_flash_cookie :notice => :not_nil
        it_changes 'Category.count' => 1
        it_sweeps_page_cache :by_page => :section
      end
    end

    with :invalid_category_params do
      it_renders :template, :new
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_sweep_page_cache
    end
  end

  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @category.id) }

    it_guards_permissions :update, :category

    with :access_granted do
      it_assigns :site, :section, :category
      it_renders :template, :edit do
        has_form_putting_to admin_category_path(@site, @section, @category) do
          shows :form
        end
      end
    end
  end

  describe "PUT to :update" do
    action do
      Category.with_observers :category_sweeper do
        put :update, default_params.merge(@params).merge(:id => @category.id)
      end
    end

    with :valid_category_params do
      it_guards_permissions :update, :category

      with :access_granted do
        before { @params[:category][:title] = 'changed' }

        it_assigns :category
        it_redirects_to { edit_admin_category_url(@site, @section, assigns(:category).id) }
        it_assigns_flash_cookie :notice => :not_nil
        it_updates :category
        it_sweeps_page_cache :by_page => :section
      end
    end

    with :invalid_category_params do
      it_renders :template, :edit
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_sweep_page_cache
    end
  end

  describe "DELETE to :destroy" do
    action do
      Category.with_observers :category_sweeper do
        delete :destroy, default_params.merge(:id => @category.id)
      end
    end

    it_guards_permissions :destroy, :category

    with :access_granted do
      it_assigns :category
      it_redirects_to { admin_categories_url }
      it_assigns_flash_cookie :notice => :not_nil
      it_destroys :category
      it_sweeps_page_cache :by_page => :section
    end
  end
end
