require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PhotosController do
  include SpecControllerHelper
  
  before :each do
    Site.delete_all
    @site   = Factory :site
    @user   = Factory :user
    @album  = Factory :album, :site => @site
    @photo  = Factory :photo, :author => @user, :section => @album
    params = {:site_id => @site.id, :section_id => @album.id}
    
    controller.stub! :require_authentication
    controller.stub!(:has_permission?).and_return true
    controller.stub!(:current_user).and_return @user
    User.stub!(:find).and_return @user
    # Stubs to admin::base_controller
    Site.stub!(:find).and_return @site
    @site.sections.stub!(:find).and_return @album
    
    set_resource_paths :photos, "/admin/sites/#{@site.id}/sections/#{@album.id}/"
    set_resource_paths :photos, "/admin/sites/#{@site.id}/sections/#{@album.id}/"
  end
  
  it "is kind of admin::base_controller" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "GET to index" do
    act! { request_to :get, @collection_path }
    it_assigns :photos
    it_renders_template :index
    it_guards_permissions :show, :photo
    
    it "finds all the photos from section.photos" do
      @album.should_receive(:photos).and_return [@photo]
      act!
    end
  end
  
  describe "GET to new" do
    before :each do
      @photo = Photo.new(:section_id => @album.id, :comment_age => @album.comment_age, :filter => @album.content_filter)
      @album.photos.stub!(:build).and_return(@photo)
    end
    act! { request_to :get, @new_member_path }
    it_assigns :photo
    it_renders_template :new
    it_guards_permissions :create, :photo
    
    it "instantiates a new photo from section.photos" do
      @album.photos.should_receive(:build).and_return @photo
      act!
    end
  end
  
  describe "POST to create" do
    before :each do
      @album.photos.stub!(:build).and_return @photo
    end
    act! { request_to :post, @member_path, {:photo => {:author => "#{@user.id}"}} }
    it_assigns :photo
    it_guards_permissions :create, :photo
    
    it "instantiates a new photo from section.photos" do
      @album.photos.should_receive(:build).and_return @photo
      act!
    end
    
    describe "with valid parameters" do
      before :each do
        @photo.stub!(:save).and_return(true)
      end
      it_redirects_to { @member_path + "#{@photo.id}/edit" }
      it_assigns_flash_cookie :notice => :not_nil
      
      it "saves the photo" do
        @photo.should_receive(:save).and_return true
        act!
      end
    end
    
    describe "with invalid parameters" do
      before :each do
        @photo.stub!(:save).and_return false
      end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end
    
  describe "GET to edit" do
    before :each do
      @album.photos.stub!(:build).and_return(@photo)
    end
    act! { request_to :get, @member_path + "#{@photo.id}/edit" }
    it_assigns :photo
    it_renders_template :edit
    it_guards_permissions :update, :photo
    
    it "instantiates finds the photo from section.photos" do
      @album.photos.should_receive(:find).and_return @photo
      act!
    end
  end
  
  describe "PUT to update" do
    before :each do
      @album.photos.stub!(:find).and_return @photo
    end
    act! { request_to :put, @member_path + "#{@photo.id}", {:photo => { :author => "#{@user.id}"}} }
    it_assigns :photo
    it_guards_permissions :update, :photo
    
    it "instantiates a new photo from section.photos" do
      @album.photos.should_receive(:find).and_return @photo
      act!
    end
    
    describe "with valid parameters" do
      before :each do
        @photo.stub!(:update_attributes).and_return(true)
      end
      it_redirects_to { @member_path + "#{@photo.id}/edit" }
      it_assigns_flash_cookie :notice => :not_nil
      
      it "updates the photo" do
        @photo.should_receive(:update_attributes).and_return true
        act!
      end
    end
    
    describe "with invalid parameters" do
      before :each do
        @photo.stub!(:update_attributes).and_return false
      end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "DELETE to destroy" do
    before :each do
      @album.photos.stub!(:find).and_return @photo
    end
    act! { request_to :delete, "/admin/sites/#{@site.id}/sections/#{@album.id}/photos/#{@photo.id}" }
    it_assigns :photo
    it_assigns_flash_cookie :notice => :not_nil
    it_guards_permissions :destroy, :photo
    it_redirects_to { admin_photos_path(@site, @album) }
    
    it "deletes the photo" do
      @photo.should_receive :destroy
      act!
    end
  end
end


describe Admin::PhotosController, "page_cache" do
  include SpecControllerHelper

  before :each do
    @filter = Admin::PhotosController.filter_chain.find PhotoSweeper.instance
  end

  it "activates the PhotoSweeper as an around filter" do
    @filter.should be_kind_of(ActionController::Filters::AroundFilter)
  end

  it "configures the PhotoSweeper to observe Photo create, update and destroy events" do
    @filter.options[:only].to_a.sort.should == ['create', 'destroy', 'update']
  end
end

describe "PhotoSweeper" do
  include SpecControllerHelper
  controller_name 'admin/photos'

  before :each do
    Site.delete_all
    @site   = Factory :site
    @user   = Factory :user
    @album  = Factory :album, :site => @site
    @photo  = Factory :photo, :author => @user, :section => @album
    @sweeper = PhotoSweeper.instance
  end

  it "observes Photo" do
    ActiveRecord::Base.observers.should include(:photo_sweeper)
  end

  it "should expire pages that reference the photo's section when the photo is created" do
    @sweeper.should_receive(:expire_cached_pages_by_section).with(@photo.section)
    @sweeper.after_create(@photo)
  end

  it "should expire pages that reference the photo when the photo is saved" do
    @sweeper.should_receive(:expire_cached_pages_by_reference).with(@photo)
    @sweeper.before_save(@photo)
  end
end