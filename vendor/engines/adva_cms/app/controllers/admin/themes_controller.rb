class Admin::ThemesController < Admin::BaseController
  layout "admin"  
  
  before_filter :set_theme, :only => [:show, :use, :edit, :update, :destroy, :export]
  
  guards_permissions :theme, :update => [:select, :unselect], :show => :export, :create => :import

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
      redirect_to admin_theme_path(@site, @theme.id)
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
  
  def import
    if request.post?
      file = ensure_uploaded_theme_file_saved params[:theme][:file]
      p file
      if @site.themes.import file
        flash.now[:notice] = "The theme has been imported."
        redirect_to admin_themes_path
      else
        flash.now[:error] = "The file could not be imported as a theme."
      end
    end
  end
  
  def export
    zip_path = @theme.export
    send_file(zip_path.to_s, :stream => false) rescue raise "Error sending #{zip_path} file"
  ensure
    FileUtils.rm_r File.dirname(zip_path)
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
    
    def ensure_uploaded_theme_file_saved(file)
      if file.path
        file
      else
        tmp_file = ActionController::UploadedTempfile.new("uploaded-theme")
        tmp_file.write file.read
        tmp_file.original_path = file.original_path
        tmp_file.read # no idea why we need this here, otherwise the zip can't be opened in Theme::import
        tmp_file
      end      
    end
end
