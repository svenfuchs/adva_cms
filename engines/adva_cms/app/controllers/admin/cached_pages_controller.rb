class Admin::CachedPagesController < Admin::BaseController
  content_for :'main_left', :sites_manage, :only => { :action => [:index, :show, :new, :edit] } do
    Menu.instance(:'admin.sites.manage').render(self)
  end

  content_for :'main_right', :cached_pages_actions, :only => { :action => [:index, :show, :new, :edit] } do
    Menu.instance(:'admin.cached_pages.actions').render(self)
  end

  before_filter :set_cached_pages, :only => :index
  before_filter :set_cached_page, :only => :destroy

  layout 'admin', :except => [:destroy]

  guards_permissions :cached_page, :manage => [:index, :destroy, :clear]

  def index
  end

  def destroy
    self.class.expire_page @cached_page.url
    @cached_page.destroy
    respond_to { |format| format.js }
  end

  def clear
    expire_site_page_cache

    flash[:notice] = t(:'adva.cached_pages.flash.clear.success')
    redirect_to admin_cached_pages_path
  end

  private
    def set_cached_pages
      conditions = params[:query] ? ['url LIKE ?', ["%#{params[:query]}%"]] : nil
      @cached_pages = @site.cached_pages.paginate :page => current_page, :conditions => conditions, :include => :references
    end

    def set_cached_page
      @cached_page = @site.cached_pages.find params[:id]
    end
end
