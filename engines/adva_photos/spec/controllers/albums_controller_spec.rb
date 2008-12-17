require File.dirname(__FILE__) + '/../spec_helper'

describe AlbumsController do
  include SpecControllerHelper
  
  before :each do
    @site  = Factory :site
    @album = Factory :album
    Site.stub!(:find).and_return @site
    @site.sections.stub!(:find).and_return @album
  end
  
  it "is kind of base_controller" do
    controller.should be_kind_of(BaseController)
  end
  
  describe "GET to show" do
    act! { request_to :get, "/albums/#{@album.id}" }
    it_assigns :album
  end
end