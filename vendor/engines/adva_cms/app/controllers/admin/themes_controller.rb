class Admin::ThemesController < Admin::BaseController
  layout "admin"  
  
  before_filter :set_theme, :only => [:show, :use, :preview, :edit, :update, :destroy]
  
  guards_permissions :theme, :update => [:select, :unselect]

  def index
    @themes = @site.themes.find(:all)
  end
  
  def show
  end

  def new
    @theme = Theme.new
  end

  def create
    @theme = @site.themes.build params[:theme]
    if @theme.save
      flash[:notice] = "The theme has been created."
      redirect_to admin_themes_path
    else
      flash.now[:error] = "The theme could not be created: #{@theme.errors.to_sentence}."
      render :action => :new
    end
  end
   
  def update
    if @theme.update_attributes params[:theme]
      flash[:notice] = "The theme has been updated."
      redirect_to admin_theme_path
    else
      flash.now[:error] = "The theme could not be updated: #{@theme.errors.to_sentence}."
      render :action => :show
    end
  end
  
  def destroy
    if @theme.destroy
      expire_pages_by_site!
      # TODO theme should also be unselected here
      flash[:notice] = "The theme has been deleted."
      redirect_to admin_themes_path
    else
      flash.now[:error] = "The theme could not be deleted."
      render :action => :show
    end
  end
  
  def select
    @site.theme_names_will_change!
    @site.theme_names << params[:id]
    @site.theme_names.uniq!
    @site.save
    expire_pages_by_site!
    redirect_to admin_themes_path
  end
  
  def unselect
    @site.theme_names_will_change!
    @site.theme_names.delete params[:id]
    @site.save
    expire_pages_by_site!
    redirect_to admin_themes_path
  end
  
  private
  
    def expire_pages_by_site!
      expire_pages CachedPage.find_all_by_site_id(@site.id)
    end
  
    def set_site
      @site = Site.find(params[:site_id])
    end
  
    def set_theme
      @theme = @site.themes.find(params[:id]) or raise "can not find theme #{params[:id]}"
    end
end
