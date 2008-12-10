require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::PhotosController do
  include SpecControllerHelper
  
  it "is kind of admin::base_controller" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "GET to index" do
    act! { request_to :get, admin_albums_path }
  end
end