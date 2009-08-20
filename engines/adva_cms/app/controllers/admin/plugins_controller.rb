class Admin::PluginsController < Admin::BaseController
  before_filter :set_plugins, :only => :index
  before_filter :set_plugin, :only => [:show, :edit, :update, :destroy]

  guards_permissions :site, :manage => [:index, :show, :update, :destroy]

  def index
  end

  def show
  end

  def update
    @plugin.options = params[:plugin]
    @plugin.save!
    flash[:notice] = t(:'adva.plugins.flash.update.success')
    redirect_to admin_plugin_url(@site, @plugin)
  end

  def destroy
    @plugin.options = {}
    @plugin.save!
    flash[:notice] = t(:'adva.plugins.flash.destroy.success')
    redirect_to admin_plugin_url(@site, @plugin)
  end

  protected

    def set_menu
      @menu = Menus::Admin::Plugins.new
    end

    def set_plugins
      @plugins = @site.plugins.values
    end

    def set_plugin
      @plugin = @site.plugins[params[:id].to_sym] or raise ActiveRecord::RecordNotFound
    end
end
