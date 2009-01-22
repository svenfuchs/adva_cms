require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::SetsController do
  include SpecControllerHelper

  before :each do
    Site.delete_all
    @user   = Factory :user
    @site   = Factory :site
    @album  = Factory :album, :site => @site
    @photo  = Factory :photo, :section => @album, :author => @user
    @set    = Factory :set,   :section => @album
    @user.roles << Rbac::Role.build(:admin, :context => @site)
    
    set_resource_paths :set, "/admin/sites/#{@site.id}/sections/#{@album.id}/"
    
    controller.stub!(:current_user).and_return @user
    Site.stub!(:find).and_return @site
    @site.sections.stub!(:find).and_return @album
  end

  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => "/admin/sites/1/sections/1/", :site_id => "1", :section_id => "1" do |route|
      route.it_maps :get, "sets", :index
      route.it_maps :get, "sets/1", :show, :id => '1'
      route.it_maps :get, "sets/new", :new
      route.it_maps :post, "sets", :create
      route.it_maps :get, "sets/1/edit", :edit, :id => '1'
      route.it_maps :put, "sets/1", :update, :id => '1'
      route.it_maps :delete, "sets/1", :destroy, :id => '1'
    end
  end

  describe "GET to :index" do
    act! { request_to :get, @collection_path }
    it_assigns :sets
    it_renders_template :index
    it_guards_permissions :show, :category
    
    it "finds all the sets from section.sets" do
      @album.should_receive(:sets).and_return [@set]
      act!
    end
  end

  describe "GET to :new" do
    before :each do
      @set = Set.new :section => @album
      @album.sets.stub!(:build).and_return @set
    end
    act! { request_to :get, @new_member_path }
    it_guards_permissions :create, :category
    it_assigns :set
    it_renders_template :new

    it "instantiates a new set from section.sets" do
      @album.sets.should_receive(:build).and_return @set
      act!
    end
  end

  describe "POST to :create" do
    before :each do
      @set = Set.new :section => @album
      @album.sets.stub!(:build).and_return @set
      @set.stub!(:save).and_return true
    end
    act! { request_to :post, @collection_path }
    it_guards_permissions :create, :category
    it_assigns :set

    it "instantiates a new set from section.sets" do
      @album.sets.should_receive(:build).and_return @set
      act!
    end

    describe "given valid set params" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end

    describe "given invalid set params" do
      before :each do 
        @set.stub!(:save).and_return false 
      end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "GET to :edit" do
    act! { request_to :get, @edit_member_path }
    it_guards_permissions :update, :category
    it_assigns :set
    it_renders_template :edit

    it "fetches a set from section.sets" do
      @album.sets.should_receive(:find).any_number_of_times.and_return @set
      act!
    end
  end

  describe "PUT to :update" do
    before :each do
      @set = Set.new :section => @album
      @album.sets.stub!(:find).and_return @set
      @set.stub!(:update_attributes).and_return true
    end
    act! { request_to :put, @member_path }
    it_guards_permissions :update, :category
    it_assigns :set

    it "fetches a set from section.sets" do
      @album.sets.should_receive(:find).and_return @set
      act!
    end

    it "updates the set with the set params" do
      @set.should_receive(:update_attributes).and_return true
      act!
    end

    describe "given valid set params" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end

    describe "given invalid set params" do
      before :each do 
        @set.stub!(:update_attributes).and_return false
      end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "DELETE to :destroy" do
    before :each do
      @album.sets.stub!(:find).and_return @set
    end
    act! { request_to :delete, @member_path }
    it_guards_permissions :destroy, :category
    it_assigns :set
    it_redirects_to { @collection_path }
    it_assigns_flash_cookie :notice => :not_nil

    it "fetches a set from section.sets" do
      @album.sets.should_receive(:find).and_return @set
      act!
    end

    it "should destroy the set" do
      @set.should_receive :destroy
      act!
    end
  end
end

describe Admin::SetsController, "page_caching" do
  include SpecControllerHelper

  it "should activate the CategorySweeper" do
    Admin::SetsController.should_receive(:cache_sweeper) do |*args|
      args.should include(:category_sweeper)
    end
    load 'admin/sets_controller.rb'
  end

  it "should have the CategorySweeper observe Set create, update and destroy events" do
    Admin::SetsController.should_receive(:cache_sweeper) do |*args|
      options = args.extract_options!
      options[:only].to_a.map(&:to_s).sort.should == ['create', 'destroy', 'update']
    end
    load 'admin/sets_controller.rb'
  end
end

describe Admin::SetsController, "CategorySweeper" do
  include SpecControllerHelper

  before :each do
    @set.stub!(:section).and_return @album
    @sweeper = CategorySweeper.instance
  end

  it "should expire pages that reference the set when the set was saved" do
    @sweeper.should_receive(:expire_cached_pages_by_section).with(@album)
    @sweeper.after_save(@set)
  end
end
