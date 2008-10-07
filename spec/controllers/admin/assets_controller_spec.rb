require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::AssetsController do
 include SpecControllerHelper
 include MockInvalidRecord

 before :each do
   scenario :site_with_assets
   set_resource_paths :asset, '/admin/sites/1/'
   @parameters = {:assets => {:title => 'test asset'}}
   @controller.stub! :require_authentication
   @controller.stub!(:has_permission?).and_return true
   @controller.stub!(:current_user).and_return stub_user
   #User.stub!(:find).and_return stub_user
 end

 it "should be an Admin::BaseController" do
   controller.should be_kind_of(Admin::BaseController)
 end

 describe "routing" do
   with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |route|
     route.it_maps :get, "assets", :index
     route.it_maps :get, "assets/1", :show, :id => '1'
     route.it_maps :get, "assets/new", :new
     route.it_maps :post, "assets", :create
     route.it_maps :get, "assets/1/edit", :edit, :id => '1'
     route.it_maps :put, "assets/1", :update, :id => '1'
     route.it_maps :delete, "assets/1", :destroy, :id => '1'
   end
 end
 
 describe "POST to :create" do
   act! { request_to :post, @collection_path, @parameters }
 
   before :each do
     @site.assets.stub!(:build).and_return @assets 
   end
   
   it "instantiates a new asset from site.assets" do
     @site.assets.should_receive(:build).and_return @assets
     act!
   end
 
   describe "given valid article params" do
     it_redirects_to { @collection_path }
     it_assigns_flash_cookie :notice => :not_nil
   end
 
   describe "given invalid asset params" do
     before :each do 
       @asset.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(mock_invalid_record))
     end
     it_renders_template :new
   end
 end
end
