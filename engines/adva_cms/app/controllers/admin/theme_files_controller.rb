class Admin::ThemeFilesController < Admin::BaseController
  layout "admin"

  before_filter :set_theme
  before_filter :set_file, :only => [:show, :update, :destroy]

  guards_permissions :theme, :update => [:index, :show, :new, :create, :import, :edit, :update, :destroy]

  def show
  end

  def new
    @file = Theme::File.new @theme
  end

  def create
    @file = Theme::File.create @theme, params[:file]
    if @file = Array(@file).first
      expire_pages_by_site! # TODO use active_model?
      expire_template! @file
      flash[:notice] = t(:'adva.theme_files.flash.create.success')
      redirect_to admin_theme_file_path(@site, @theme.id, @file.id)
    else
      flash.now[:error] = t(:'adva.theme_files.flash.create.failure')
      render :action => :new
    end
  end

  def update
    if @file.update_attributes params[:file]
      expire_pages_by_site! # TODO use active_model?
      expire_template! @file
      flash[:notice] = t(:'adva.theme_files.flash.update.success')
      redirect_to admin_theme_file_path(@site, @theme.id, @file.id)
    else
      flash.now[:error] = t(:'adva.theme_files.flash.update.failure')
      render :action => :show
    end
  end

  def destroy
    if @file.destroy
      expire_pages_by_site! # TODO use active_model?
      expire_template! if @file.is_a?(Theme::Template)
      flash[:notice] = t(:'adva.theme_files.flash.destroy.success')
      redirect_to admin_theme_path(@site, @theme.id)
    else
      flash.now[:error] = t(:'adva.theme_files.flash.destroy.failure')
      render :action => :show
    end
  end

  private

    def expire_pages_by_site!
      # this misses assets like stylesheets which aren't tracked
      # expire_pages CachedPage.find_all_by_site_id(@site.id)
      expire_site_page_cache
    end

    def expire_template!(file)
      # this will expire compiled actionview templates from memory
      # see lib/theme_support/compiled_template_expiration
      FileUtils.touch(@theme.path)
    end

    def set_theme
      @theme = @site.themes.find(params[:theme_id]) or raise "can not find theme #{params[:theme_id]}"
    end

    def set_file
      @file = @theme.files.find params[:id]
      raise "can not find file #{params[:id]}" unless @file and @file.valid?
    end
end
