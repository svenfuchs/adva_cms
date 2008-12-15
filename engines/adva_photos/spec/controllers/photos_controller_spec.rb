require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::PhotosController do
  include SpecControllerHelper
  
  before :each do
    @site   = Factory :site
    @user   = Factory :user
    @album  = Factory :album, :site => @site
    @photo  = @album.photos.build Factory.attributes_for(:photo, :author => @user)
    params = {:site_id => @site.id, :section_id => @album.id}
    
    controller.stub! :require_authentication
    controller.stub!(:has_permission?).and_return true
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
end