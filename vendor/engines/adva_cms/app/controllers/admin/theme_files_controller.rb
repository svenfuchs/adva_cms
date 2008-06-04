class Admin::ThemeFilesController < Admin::BaseController
  layout "admin"
  
  before_filter :set_theme
  before_filter :set_file, :only => [:show, :update, :destroy]
  
  guards_permissions :manage_themes

  def new
    @file = Theme::File.new @theme
  end

  def create
    @file = Theme::File.create @theme, params[:file]
    if @file = Array(@file).first
      flash[:notice] = "The file has been created."
      redirect_to admin_theme_file_path(@site, @theme.id, @file.id)
    else
      flash.now[:error] = "The file could not be created."
      render :action => :new
    end
  end

  def update
    if @file.update_attributes params[:file]
      flash[:notice] = "The file has been updated."
      redirect_to admin_theme_file_path(@site, @theme.id, @file.id)
      # site.expire_cached_pages self, "Expired all referenced pages" if current_theme? # TODO
    else
      flash.now[:error] = "The file could not be updated."
      render :action => :show
    end
  end

  def destroy
    if @file.destroy
      flash[:notice] = "The file has been deleted."
      redirect_to admin_theme_path(@site, @theme.id)
    else
      flash.now[:error] = "The file could not be deleted."
      render :action => :show
    end
  end
  
  private
  
    def set_theme
      @theme = @site.themes.find(params[:theme_id]) or raise "can not find theme #{params[:theme_id]}"
    end
  
    def set_file
      @file = @theme.files.find params[:id]
      raise "can not find file #{params[:id]}" unless @file and @file.valid?      
    end
end
