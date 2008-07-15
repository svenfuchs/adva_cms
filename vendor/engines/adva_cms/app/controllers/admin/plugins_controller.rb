class Admin::PluginsController < Admin::BaseController
  before_filter :set_plugins, :only => :index
  before_filter :set_plugin, :only => [:show, :edit, :update, :destroy]
  
  def index    
  end
  
  def show
  end
  
  def update
    @plugin.options = params[:plugin]
    @plugin.save!
    flash[:notice] = "The plugin settings have been updated."
    redirect_to admin_plugin_path(@site, @plugin)
  end
  
  def destroy
    @plugin.options = {}
    @plugin.save!
    flash[:notice] = "The default settings have been restored."
    redirect_to admin_plugin_path(@site, @plugin)
  end
  
  protected
  
    def set_plugins
      @plugins = @site.plugins
    end
    
    def set_plugin
      @plugin = @site.plugins[params[:id]] or raise ActiveRecord::RecordNotFound
    end
end