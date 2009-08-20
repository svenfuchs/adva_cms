class Admin::AssetContentsController < Admin::BaseController
  layout false

  before_filter :set_asset, :set_content
  helper :'admin/assets'
  guards_permissions :asset, :manage => [:create, :destroy]

  def create
    @asset.contents << @content
    @asset.save

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @asset.contents.delete @content
    @asset.save

    respond_to do |format|
      format.js
    end
  end

  private

    def set_asset
      @asset = @site.assets.find params[:asset_id]
    end

    def set_content
      key = params[:action] == 'create' ? :content_id : :id
      @content = ::Content.find params[key], :include => 'section'
      raise "no access" if @content.section.site_id != @site.id
    end

end