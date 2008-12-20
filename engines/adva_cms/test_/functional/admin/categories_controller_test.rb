require File.dirname(__FILE__) + "/../../test_helper"
  
class AdminCategoriesControllerTest < ActionController::TestCase
  tests Admin::CategoriesController

  def setup
    super
    login_as_superuser!
  end
  
  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end

  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |route|
      route.it_maps :get, "categories", :index
      route.it_maps :get, "categories/1", :show, :id => '1'
      route.it_maps :get, "categories/new", :new
      route.it_maps :post, "categories", :create
      route.it_maps :get, "categories/1/edit", :edit, :id => '1'
      route.it_maps :put, "categories/1", :update, :id => '1'
      route.it_maps :delete, "categories/1", :destroy, :id => '1'
    end
  end

  describe "GET to :index" do
    act! { request_to :get, @collection_path }
    # it_guards_permissions :show, :category # deactivated all :show permissions in the backend
    it_assigns :categories
    it_renders_template :index
  end

  describe "GET to :new" do
    act! { request_to :get, @new_member_path }
    it_guards_permissions :create, :category
    it_assigns :category
    it_renders_template :new

    it "instantiates a new category from section.categories" do
      @section.categories.should_receive(:build).any_number_of_times.and_return @category
      act!
    end
  end

  describe "POST to :create" do
    act! { request_to :post, @collection_path }
    it_guards_permissions :create, :category
    it_assigns :category

    it "instantiates a new category from section.categories" do
      @section.categories.should_receive(:build).any_number_of_times.and_return @category
      act!
    end

    describe "given valid category params" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end

    describe "given invalid category params" do
      before :each do @category.stub!(:save).and_return false end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "GET to :edit" do
    act! { request_to :get, @edit_member_path }
    it_guards_permissions :update, :category
    it_assigns :category
    it_renders_template :edit

    it "fetches a category from section.categories" do
      @section.categories.should_receive(:find).any_number_of_times.and_return @category
      act!
    end
  end

  describe "PUT to :update" do
    act! { request_to :put, @member_path }
    it_guards_permissions :update, :category
    it_assigns :category

    it "fetches a category from section.categories" do
      @section.categories.should_receive(:find).any_number_of_times.and_return @category
      act!
    end

    it "updates the category with the category params" do
      @category.should_receive(:update_attributes).any_number_of_times.and_return true
      act!
    end

    describe "given valid category params" do
      it_redirects_to { @edit_member_path }
      it_assigns_flash_cookie :notice => :not_nil
    end

    describe "given invalid category params" do
      before :each do @category.stub!(:update_attributes).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "DELETE to :destroy" do
    act! { request_to :delete, @member_path }
    it_guards_permissions :destroy, :category
    it_assigns :category

    it "fetches a category from section.categories" do
      @section.categories.should_receive(:find).any_number_of_times.and_return @category
      act!
    end

    it "should try to destroy the category" do
      @category.should_receive :destroy
      act!
    end

    describe "when destroy succeeds" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end

    describe "when destroy fails" do
      before :each do @category.stub!(:destroy).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
end

describe Admin::CategoriesController, "page_caching" do
  include SpecControllerHelper

  it "should activate the CategorySweeper" do
    Admin::CategoriesController.should_receive(:cache_sweeper) do |*args|
      args.should include(:category_sweeper)
    end
    load 'admin/categories_controller.rb'
  end

  it "should have the CategorySweeper observe Category create, update and destroy events" do
    Admin::CategoriesController.should_receive(:cache_sweeper) do |*args|
      options = args.extract_options!
      options[:only].to_a.map(&:to_s).sort.should == ['create', 'destroy', 'update']
    end
    load 'admin/categories_controller.rb'
  end
end

describe Admin::CategoriesController, "CategorySweeper" do
  include SpecControllerHelper

  before :each do
    @category.stub!(:section).and_return stub_section
    @sweeper = CategorySweeper.instance
  end

  it "should expire pages that reference an category when an category was saved" do
    @sweeper.should_receive(:expire_cached_pages_by_section).with(stub_section)
    @sweeper.after_save(stub_category)
  end
end
