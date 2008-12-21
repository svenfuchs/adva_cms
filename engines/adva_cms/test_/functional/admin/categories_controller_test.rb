require File.dirname(__FILE__) + "/../../test_helper"

# With.aspects << :access_control

class AdminCategoriesControllerTest < ActionController::TestCase
  tests Admin::CategoriesController

  def setup
    super
    login_as_superuser!
  end
  
  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end
   
  test "is an Admin::BaseController" do
    Admin::BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
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

  describe "GET to :index" do
    action { get :index, default_params }
    
    with :an_empty_section do
      with :a_category do
        it_guards_permissions :show, :category
      
        with :access_granted do
          it_assigns :site, :section, :categories
          it_renders_template :index
        end
      end
    end
  end

  describe "GET to :new" do
    action { get :new, default_params }
    
    with :an_empty_section do
      it_guards_permissions :create, :category
      
      with :access_granted do
        it_assigns :site, :section
        it_renders_template :new
      end
    end
  end
  
  describe "POST to :create" do
    action do
      Category.with_observers :category_sweeper do
        post :create, default_params.merge(@params)
      end
    end
    
    with :an_empty_section do
      with :valid_category_params do
        it_guards_permissions :create, :category

        with :access_granted do
          it_assigns :category
          it_redirects_to { admin_categories_path }
          it_assigns_flash_cookie :notice => :not_nil
          it_changes 'Category.count' => 1
          it_sweeps_page_cache :by_section => :section
        end
      end
    
      with :invalid_category_params do
        it_renders_template :new
        it_assigns_flash_cookie :error => :not_nil
        it_does_not_sweep_page_cache
      end
    end
  end
   
  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @category.id) }
  
    with :an_empty_section do
      with :a_category do
        it_guards_permissions :update, :category
        
        with :access_granted do
          it_assigns :site, :section, :category
          it_renders_template :edit
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
    
    with :an_empty_section do
      with :a_category do
        with :valid_category_params do
          it_guards_permissions :update, :category
        
          with :access_granted do
            before { @params[:category][:title] = 'changed' }
          
            it_assigns :category
            it_redirects_to { edit_admin_category_path(@site, @section, assigns(:category).id) }
            it_assigns_flash_cookie :notice => :not_nil
            it_updates :category
            it_sweeps_page_cache :by_section => :section
          end
        end
      
        with :invalid_category_params do
          it_renders_template :edit
          it_assigns_flash_cookie :error => :not_nil
          it_does_not_sweep_page_cache
        end
      end
    end
  end
  
  describe "DELETE to :destroy" do
    action do
      Category.with_observers :category_sweeper do
        delete :destroy, default_params.merge(:id => @category.id)
      end
    end

    with :an_empty_section do
      with :a_category do
        it_guards_permissions :destroy, :category
      
        with :access_granted do
          it_assigns :category
          it_redirects_to { admin_categories_path }
          it_assigns_flash_cookie :notice => :not_nil
          it_destroys :category
          it_sweeps_page_cache :by_section => :section
        end
      end
    end
  end
  
# describe Admin::CategoriesController, "page_caching" do
#   include SpecControllerHelper
# 
#   it "should activate the CategorySweeper" do
#     Admin::CategoriesController.should_receive(:cache_sweeper) do |*args|
#       args.should include(:category_sweeper)
#     end
#     load 'admin/categories_controller.rb'
#   end
# 
#   it "should have the CategorySweeper observe Category create, update and destroy events" do
#     Admin::CategoriesController.should_receive(:cache_sweeper) do |*args|
#       options = args.extract_options!
#       options[:only].to_a.map(&:to_s).sort.should == ['create', 'destroy', 'update']
#     end
#     load 'admin/categories_controller.rb'
#   end
# end
# 
# describe Admin::CategoriesController, "CategorySweeper" do
#   include SpecControllerHelper
# 
#   before :each do
#     @category.stub!(:section).and_return stub_section
#     @sweeper = CategorySweeper.instance
#   end
# 
#   it "should expire pages that reference an category when an category was saved" do
#     @sweeper.should_receive(:expire_cached_pages_by_section).with(stub_section)
#     @sweeper.after_save(stub_category)
#   end
end
