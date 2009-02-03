require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class AdminAssetsControllerTest < ActionController::TestCase
  include AssetsHelper
  tests Admin::AssetsController
  
  with_common :a_site, :an_asset, :is_superuser
  
  def default_params
    { :site_id => @site.id }
  end

  test "is an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |r|
      r.it_maps :get,    "assets",        :action => 'index'
      r.it_maps :get,    "assets/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "assets/new",    :action => 'new'
      r.it_maps :post,   "assets",        :action => 'create'
      r.it_maps :get,    "assets/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "assets/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "assets/1",      :action => 'destroy', :id => '1'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params }
    # FIXME
    # it_guards_permissions :show, :asset
    
    with :access_granted do
      it_assigns :recent
      it_renders :template, :index
    end
  end
  
  describe "POST to :create" do
    action { post :create, default_params.merge(@params) }
    
    with :valid_asset_params do
      # FIXME
      # it_guards_permissions :create, :asset
  
      with :access_granted do
        it_assigns :site, :assets
        it_changes '@site.reload.assets.count' => 1
        it_assigns_flash_cookie :notice => :not_nil
        it_redirects_to { admin_assets_path(@site.id) }
      end
    end
  
    with :invalid_asset_params, :access_granted do
      it_assigns :site, :assets
      it_does_not_change '@site.reload.assets.count'
      it_renders :template, :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "PUT to :update" do
    action { put :update, default_params.merge(@params).merge(:id => @asset.id) }
  
    with :valid_asset_params do
      # FIXME
      # it_guards_permissions :update, :article
      
      with :access_granted do
        it_assigns :site, :asset
        it_updates :asset
        it_redirects_to { admin_assets_path(@site) }
        it_assigns_flash_cookie :notice => :not_nil
      end
    end
    
    # FIXME what asset params would be invalid?
    # with :invalid_asset_params, :access_granted do
    #   it_assigns :site, :asset
    #   it_renders :template, :edit
    #   it_assigns_flash_cookie :error => :not_nil
    # end
  end
  
  describe "DELETE to :destroy" do
    action { delete :destroy, default_params.merge(:id => @asset.id) }
    
    # FIXME
    # it_guards_permissions :destroy, :asset
    
    with :access_granted do
      it_assigns :site, :asset
      it_destroys :asset
      it_redirects_to { admin_assets_path(@site) }
      
      # FIXME
      # before do
      #   # @session[:bucket] = { @asset.id => asset_image_args_for(@asset, :tiny) }
      # end
      # it "removes the asset from the session bucket" do
      #   # session[:bucket]
      # end
    end
  end
end
