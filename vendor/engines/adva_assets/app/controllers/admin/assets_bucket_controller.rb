class Admin::AssetsBucketController < Admin::BaseController
  include AssetsHelper
  helper :assets
  layout false

  before_filter :set_asset, :only => [:create]

  def create
    render :nothing => true and return if (session[:bucket] ||= {}).key?(@asset.id)
    session[:bucket][@asset.id] = asset_image_args_for(@asset, :tiny, :title => "#{@asset.title} \n #{@asset.tags.join(', ')}")
  end

  def destroy
    session[:bucket] = nil
  end
  
  private
  
    def set_asset
      @asset = @site.assets.find params[:asset_id]
    end  
end