class Admin::AssetsController < Admin::BaseController
  include AssetsHelper
  helper :assets, :asset_tag
  helper_method :created_notice
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
      options = { :per_page => params[:limit] || 24, :page => current_page }
      filters = normalize_filters(params[:filters])
      @assets = site.assets.filter_by(*filters).paginate(options)
    end

    def set_asset
      @asset = @site.assets.find params[:id]
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

    # The filter bar html does not deliver exactly the filter params format that
    # could be directly piped to the filter_by scope, so we'll rearrange it. 
    # Someone with javascript superpowers might want to change this , so we could
    # get rid of this monster method.
    def normalize_filters(filters)
      return [] if filters.blank?
      filters.symbolize_keys!
      media_types, query = filters.values_at(:media_types, :query)
      returning([]) do |result|
        columns = [:title, :tags_list].reject { |column| filters[column].blank? }
        result << [:contains, columns, query] unless query.blank? or columns.empty?
        result << [:is_media_type, media_types.keys] if media_types
      end
    end
end
