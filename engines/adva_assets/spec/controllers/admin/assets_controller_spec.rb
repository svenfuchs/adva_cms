require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::AssetsController do
 include SpecControllerHelper
 include MockInvalidRecord

 before :each do
   stub_scenario :site_with_assets
   set_resource_paths :asset, '/admin/sites/1/'
   @parameters = {:assets => {:title => 'test asset'}}
   @controller.stub! :count_by_conditions
   @controller.stub! :require_authentication
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
 
 describe "GET to :index" do
   act! { request_to :get, @collection_path }
   it_assigns :recent
   it_renders_template :index
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

   it "tries to save the asset" do
     @asset.should_receive(:save!).and_return true
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
     it_assigns_flash_cookie :error => :not_nil
     it_renders_template :new
   end
 end
 
 describe "PUT to :update" do
   act! { request_to :put, @member_path, @parameters }
   it_assigns :asset
 
   it "fetches an asset from site.assets" do
     @site.assets.should_receive(:find).and_return @asset
     act!
   end
 
   it "updates the asset with the asset params" do
     @asset.should_receive(:update_attributes!).and_return true
     act!
   end
 
   describe "given valid theme params" do
     it_redirects_to { @collection_path }
     it_assigns_flash_cookie :notice => :not_nil
   end
 
   describe "given invalid theme params" do
     before :each do 
        @asset.should_receive(:update_attributes!).and_raise(ActiveRecord::RecordInvalid.new(mock_invalid_record))
      end
     it_renders_template :edit
     it_assigns_flash_cookie :error => :not_nil
   end
 end
 
 describe "DELETE to :destroy" do
   act! { request_to :delete, @member_path }
   it_assigns :asset
   it_assigns_flash_cookie :notice => :not_nil
   
   it "fetches an asset from site.assets" do
     @site.assets.should_receive(:find).and_return @asset
     act!
   end

   it "should try to destroy the asset" do
     @asset.should_receive :destroy
     act!
   end
   
   it "should remove asset from session bucket using its public filename" do
     @asset.should_receive :public_filename
     act!
   end
 end
end
