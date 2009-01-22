require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::AssetsBucketController do
 include SpecControllerHelper
 include FactoryScenario
 
 before :each do
   Site.delete_all
   factory_scenario :site_with_a_section
   
   @controller.stub! :require_authentication
   @controller.stub!(:has_permission?).and_return true
   
   @asset = Asset.create!(:filename => 'testfile', :site => @site, :size => 100, :content_type => 'text')
   @content = Content.create!(:title => 'content', :body => 'content body',
                              :author => Factory(:user), :section => @section,
                              :site => @site)
 end

 it "should be an Admin::BaseController" do
   controller.should be_kind_of(Admin::BaseController)
 end
 
 describe "POST to create" do
   act! { post :create, { :site_id => @site.id, :asset_id => @asset.id } }
   it_assigns :asset
   it_guards_permissions :manage, :asset
   
   it "should put asset to the bucket" do
     act!
     controller.session[:bucket][@asset.id].should_not be_nil
   end
 end
 
 describe "DELETE to destroy" do
   act! { delete :destroy, { :site_id => @site.id, :asset_id => @asset.id } }
   it_guards_permissions :manage, :asset
   
   it "should empty the bucket" do
     act!
     controller.session[:bucket].should be_nil
   end
 end
end