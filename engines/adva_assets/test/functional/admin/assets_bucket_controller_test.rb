require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class AdminAssetsBucketControllerTest < ActionController::TestCase
  tests Admin::AssetsBucketController
  
  with_common :a_site, :an_asset, :is_superuser

  test "should be an Admin::BaseController" do
   @controller.should be_kind_of(Admin::BaseController)
  end

  describe "POST to create" do
    action { post :create, { :site_id => @site.id, :asset_id => @asset.id } }
    it_guards_permissions :manage, :asset
    
    with :access_granted do
      it_assigns :asset
      
      it "puts the asset to the bucket" do
        @controller.session[:bucket][@asset.id].should_not be_nil
      end
    end
  end
  
  describe "DELETE to destroy" do
    action { delete :destroy, { :site_id => @site.id, :asset_id => @asset.id } }
    it_guards_permissions :manage, :asset

    with :access_granted do
      it "empties the bucket" do
        @controller.session[:bucket].should be_nil
      end
    end
  end
end