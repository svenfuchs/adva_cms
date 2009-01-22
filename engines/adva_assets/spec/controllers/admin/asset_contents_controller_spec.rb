require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::AssetContentsController do
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
   act! { post :create, { :site_id => @site.id, :asset_id => @asset.id, :content_id => @content.id } }
   it_assigns :asset
   it_assigns :content
   it_guards_permissions :manage, :asset
   
   it "should assign @content to @asset.contents" do
     act!
     @asset.contents.should include(@content)
   end
 end
 
 describe "DELETE to destroy" do
   before :each do
     @asset.contents << @content
     @asset.save
   end
   act! { delete :destroy, { :site_id => @site.id, :asset_id => @asset.id, :id => @content.id } }
   it_assigns :asset
   it_assigns :content
   it_guards_permissions :manage, :asset
   
   it "should unassign @content to @asset.contents" do
     act!
     @asset.contents.should be_empty
   end
 end
end