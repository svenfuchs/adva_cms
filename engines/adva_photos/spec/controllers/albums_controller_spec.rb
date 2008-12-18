require File.dirname(__FILE__) + '/../spec_helper'

describe AlbumsController do
  include SpecControllerHelper
  
  before :each do
    Site.delete_all
    @site  = Factory :site
    @album = Factory :album
    @user  = Factory :user
    @photo = Factory :photo, :section => @album, :author => @user
    Site.stub!(:find_by_host).and_return @site
    @site.sections.stub!(:root).and_return @album
    @site.sections.stub!(:find).and_return @album
  end
  
  it "is kind of base_controller" do
    controller.should be_kind_of(BaseController)
  end
  
  describe "GET to index" do
    act! { request_to :get, "/albums" }
    it_assigns :section
    it_assigns :photos
  end
  
  describe "GET to show" do
    act! { request_to :get, "/albums/#{@album.id}/photos/#{@photo.id}" }
    it_assigns :section
    it_assigns :photo
  end
end