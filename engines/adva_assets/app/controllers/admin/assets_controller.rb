class Admin::AssetsController < Admin::BaseController
  include Admin::AssetsHelper
  helper :'admin/assets', :'admin/asset_tag'
  helper_method :created_notice, :destroyed_notice
  before_filter :set_assets, :only => [:index] # :set_filter_params, 
  before_filter :set_format, :only => [:create]
  before_filter :set_asset, :only => [:edit, :update, :destroy]

  guards_permissions :asset

  def index
    @recent = @assets.slice!(0, 4) if params[:source] != 'widget' # TODO hu?
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
  end

  def create
    @assets = @site.assets.build(params[:assets])
    Asset.transaction { @assets.each &:save! }

    respond_to do |format|
      format.html do
        flash[:notice] = created_notice
        redirect_to admin_assets_url
      end
      format.js do
        responds_to_parent { render :action => 'create' }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html do
        flash[:error] = t(:'adva.assets.flash.upload.failure')
        render :action => 'new'
      end
      format.js do
        responds_to_parent { render :action => 'flash_error' }
      end
    end
  end

  def edit
  end

  def update
    @asset.update_attributes!(params[:asset])
    flash[:notice] = t(:'adva.assets.flash.update.success')
    redirect_to admin_assets_url
  rescue ActiveRecord::RecordInvalid
    flash[:error] = t(:'adva.assets.flash.update.failure')
    render :action => 'edit'
  end

  def destroy
    @asset.destroy
    (session[:bucket] || {}).delete(@asset.base_url)

    respond_to do |format|
      format.html do
        flash[:notice] = destroyed_notice
        redirect_to admin_assets_url
      end
      format.js do
      end
    end
  end

  protected

    def set_menu
      @menu = Menus::Admin::Assets.new
    end

    def set_assets
      @assets = site.assets.filtered(params[:filters]).paginate(:per_page => params[:limit] || 24, :page => current_page)
    end

    def set_asset
      @asset = @site.assets.find(params[:id])
    end

    def set_format
      request.env['HTTP_ACCEPT'] = 'text/javascript,' + request.env['HTTP_ACCEPT']  if params[:respond_to_parent]
    end

    def created_notice
      # TODO: isn't the logic here backwards?
      @assets.size ?
        t(:'adva.assets.flash.create.first_success', :asset => CGI.escapeHTML(@assets.first.title) ) :
        t(:'adva.assets.flash.create.success', :count => @assets.size )
    end

    def destroyed_notice
      t(:'adva.assets.flash.delete.success', :asset => @asset.title)
    end
end
