class Admin::ThemesController < Admin::BaseController
  before_filter :set_theme, :only => [:show, :use, :edit, :update, :destroy, :export, :select, :unselect]
  # before_filter :ensure_uploaded_theme_file_saved!, :only => :import

  guards_permissions :theme, :update => [:select, :unselect], :manage => [:index, :show, :export], :create => :import

  def index
    @themes = @site.themes
  end

  def new
    @theme = Theme.new
  end

  def create
    @theme = @site.themes.build(params[:theme])
    if @theme.save
      flash[:notice] = t(:'adva.themes.flash.create.success')
      redirect_to admin_themes_url
    else
      errors = @theme.errors.full_messages.to_sentence
      flash.now[:error] = t(:'adva.themes.flash.create.failure', :errors => errors)
      render :action => :new
    end
  end

  def update
    if @theme.update_attributes(params[:theme])
      flash[:notice] = t(:'adva.themes.flash.update.success')
      redirect_to edit_admin_theme_url(@site, @theme.id)
    else
      errors = @theme.errors.full_messages.to_sentence
      flash.now[:error] = t(:'adva.themes.flash.update.failure', :errors => errors)
      render :action => :edit
    end
  end

  def destroy
    if @theme.destroy
      expire_pages_by_site!
      # TODO theme should also be unselected here
      flash[:notice] = t(:'adva.themes.flash.destroy.success')
      redirect_to admin_themes_url
    else
      flash.now[:error] = t(:'adva.themes.flash.destroy.failure')
      render :action => :show
    end
  end

  def import
    render and return unless request.post? # renders the import form

    # uploads and imports the theme
    file = params[:theme] ? params[:theme][:file] : nil
    if file.blank?
      flash.now[:error] = t(:'adva.themes.flash.import.error_filename_blank')
    elsif @site.themes.import(file)
      flash.now[:notice] = t(:'adva.themes.flash.import.success')
      redirect_to admin_themes_url
    else
      flash.now[:error] = t(:'adva.themes.flash.import.failure')
    end
  end

  def export
    zip_path = @theme.export
    send_file(zip_path.to_s, :stream => false) rescue raise "Error sending #{zip_path} file"
  ensure
    FileUtils.rm_r File.dirname(zip_path) rescue nil
  end

  def select
    @theme.activate!
    expire_pages_by_site!
    redirect_to params[:return_to] || admin_themes_url
  end

  def unselect
    @theme.deactivate!
    expire_pages_by_site!
    redirect_to params[:return_to] || admin_themes_url
  end

  protected

    def expire_pages_by_site!
      expire_site_page_cache
    end

    def set_menu
      @menu = Menus::Admin::Themes.new
    end

    def set_theme
      @theme = @site.themes.find(params[:id])
    end

    def ensure_uploaded_theme_file_saved!
      return
      return if request.get? || params[:theme][:file].blank?

      file = params[:theme][:file]
      if file.path
        @file = file
      else
        @file = ActionController::UploadedTempfile.new("uploaded-theme")
        @file.write file.read
        @file.original_path = file.original_path
        @file.read # no idea why we need this here, otherwise the zip can't be opened in Theme::import
      end
    end
end
