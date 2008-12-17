require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PhotosController do
  include SpecControllerHelper
  
  before :each do
    Site.delete_all
    @site   = Factory :site
    @user   = Factory :user
    @album  = Factory :album, :site => @site
    @photo  = @album.photos.build Factory.attributes_for(:photo, :author => @user)
    params = {:site_id => @site.id, :section_id => @album.id}
    
    controller.stub! :require_authentication
    controller.stub!(:has_permission?).and_return true
    controller.stub!(:current_user).and_return @user
    User.stub!(:find).and_return @user
    # Stubs to admin::base_controller
    Site.stub!(:find).and_return @site
    @site.sections.stub!(:find).and_return @album
    
    set_resource_paths :photos, "/admin/sites/#{@site.id}/sections/#{@album.id}/"
  end
  
  it "is kind of admin::base_controller" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "GET to index" do
    act! { request_to :get, @collection_path }
    it_assigns :photos
    it_renders_template :index
    
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
    
    it "instantiates a new photo from section.photos" do
      @album.photos.should_receive(:build).and_return @photo
      act!
    end
  end
  
  describe "POST to create" do
    before :each do
      @params = {:photo => { :title => 'test photo', :author => "#{@user.id}" }}
      @photo = Photo.new(:title => 'test photo', :author => @user)
      @album.photos.stub!(:build).and_return @photo
      
      # TODO: routing_filter does not like these paths
      controller.stub!(:edit_admin_photo_path).and_return('edit_admin_photo_path')
    end
    act! { request_to :post, @member_path, @params }
    it_assigns :photo
    
    it "instantiates a new photo from section.photos" do
      @album.photos.should_receive(:build).and_return @photo
      act!
    end
    
    describe "with valid parameters" do
      before :each do
        @photo.stub!(:save).and_return(true)
      end
      #it_redirects_to { "http://test.host/admin/sites/#{@site.id}/sections/#{@section.id}/photos/#{@photo.id}/edit" }
      it_assigns_flash_cookie :notice => :not_nil
      
      it "saves the photo" do
        @photo.should_receive(:save).and_return true
        act!
      end
    end
    
    describe "with invalid parameters" do
      before :each do
        @message.stub!(:save).and_return false
      end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end
end