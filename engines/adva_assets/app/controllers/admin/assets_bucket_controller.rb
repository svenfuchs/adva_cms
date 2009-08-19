class Admin::AssetsBucketController < Admin::BaseController
  include Admin::AssetsHelper
  helper :'admin/assets'
  layout false

  before_filter :set_asset, :only => [:create]
  guards_permissions :asset, :manage => [:create, :destroy]

  def create
    render :nothing => true and return if (session[:bucket] ||= {}).key?(@asset.id)
    session[:bucket][@asset.id] = asset_image_args_for(@asset, :tiny, :title => "#{@asset.title} \n #{@asset.tags.join(', ')}")

    respond_to do |format|
      format.js
    end
  end

  def destroy
    session[:bucket] = nil

    respond_to do |format|
      format.js
    end
  end

  private

    def set_asset
      @asset = @site.assets.find params[:asset_id]
    end
end