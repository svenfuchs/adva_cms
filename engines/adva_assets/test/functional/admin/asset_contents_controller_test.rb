require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class AdminAssetContentsController < ActionController::TestCase
  tests Admin::AssetContentsController
 
  with_common :a_page, :an_article, :an_asset, :is_superuser

  test "should be an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end
 
  describe "POST to create" do
    action { post :create, { :site_id => @site.id, :asset_id => @asset.id, :content_id => @article.id } }
    it_guards_permissions :manage, :asset
    
    with :access_granted do
      it_assigns :asset
      it_assigns :content => lambda { @article }

      it "should assign @content to @asset.contents" do
        @asset.contents.should include(@article)
      end
    end
  end
  
  describe "DELETE to destroy" do
    before :each do
      @asset.contents << @article
      @asset.save
    end
    
    action { delete :destroy, { :site_id => @site.id, :asset_id => @asset.id, :id => @article.id } }
    it_guards_permissions :manage, :asset
    
    with :access_granted do
      it_assigns :asset
      it_assigns :content => lambda { @article }
      
      it "should unassign @content from @asset.contents" do
        @asset.contents.should be_empty
      end
    end
  end
end