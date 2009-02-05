class Admin::AssetsController < Admin::BaseController
  include AssetsHelper
  helper :assets, :asset_tag
  helper_method :created_notice
  before_filter :set_search_params, :set_assets, :only => [:index]
  before_filter :set_format, :only => [:create]
  before_filter :set_asset, :only => [:edit, :update, :destroy]

  guards_permissions :asset

  def index
    @recent = @assets.slice!(0, 4) if params[:source] != 'widget'
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @assets = [Asset.new]
  end

  def create
    @assets = @site.assets.build(params[:assets].values)
    Asset.transaction { @assets.each &:save! }

    respond_to do |format|
      format.html do
        flash[:notice] = created_notice
        redirect_to(admin_assets_path)
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
    @asset.update_attributes! params[:asset]
    flash[:notice] = t(:'adva.assets.flash.update.success')
    redirect_to admin_assets_path
  rescue ActiveRecord::RecordInvalid
    flash[:error] = t(:'adva.assets.flash.update.failure')
    render :action => 'edit'
  end

  def destroy
    @asset.destroy
    redirect_to admin_assets_path
    (session[:bucket] || {}).delete(@asset.base_url)
    flash[:notice] = t(:'adva.assets.flash.delete.success', :filename => @asset.filename)
  end

  protected

    def set_assets
      @types  = params[:filter].blank? ? [] : params[:filter].keys
      options = search_options.merge(:per_page => params[:limit], :page => current_page)
      @assets = @types.empty? ? site.assets.paginate(options) : site.assets.is_media_types(@types).paginate(options)
    end

    def set_asset
      @asset = @site.assets.find params[:id]
    end

    def set_search_params
      params[:conditions] ||= { :title => true, :tags => true }
      params[:query] = params[:query].downcase + '%' unless params[:query].blank?
      params[:limit] ||= 24
    end

    def set_format
      request.env['HTTP_ACCEPT'] = 'text/javascript,' + request.env['HTTP_ACCEPT']  if params[:respond_to_parent]
    end

    def created_notice
      # TODO: is the logic here backwards?
      @assets.size ?
        t(:'adva.assets.flash.create.first_success', :asset => CGI.escapeHTML(@assets.first.title) ) :
        t(:'adva.assets.flash.create.success', :count => @assets.size )
    end

    def search_options
      return @search_options if @search_options
    
      @search_options = returning :conditions => [] do |options|
        options[:include] = []
        unless params[:query].blank?
          if params[:conditions].has_key?(:title)
            options[:conditions] << Asset.send(:sanitize_sql, ['(LOWER(assets.title) LIKE :query or LOWER(assets.filename) LIKE :query)', {:query => params[:query]}])
          end
          if params[:conditions].has_key?(:tags)
            options[:include] << :tags
            options[:conditions] << Asset.send(:sanitize_sql, ["(taggings.taggable_type = 'Asset' and tags.name IN (?))", TagList.from(params[:query].chomp("%"))])
          end
        end
        options[:conditions].blank? ? options.delete(:conditions) : options[:conditions] *= ' OR '
        options.delete(:include) if options[:include].empty?
      end
    end
end
