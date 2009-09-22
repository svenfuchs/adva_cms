class Admin::CachedPagesController < Admin::BaseController
  before_filter :set_cached_pages, :only => :index
  before_filter :set_cached_page, :only => :destroy

  layout 'admin', :except => [:destroy]

  guards_permissions :cached_page, :manage => [:index, :destroy, :clear]

  def index
    # FIXME caching
    # how to list cached pages? maybe allow users to enter a url meanwhile
  end

  def destroy
    # FIXME caching
    # self.class.expire_page @cached_page.url
    # @cached_page.destroy
    # respond_to { |format| format.js }
  end

  def clear
    # FIXME caching
    # tag responses with the site name, then expire all this way
    # have channels for rack-cache keys? could flush a whole channel
    # expire_site_page_cache
    
    # FIXME there is most probably more intelligent place to put this
    @site.themes.each { |theme| theme.clear_asset_cache! }
    
    flash[:notice] = t(:'adva.cached_pages.flash.clear.success')
    redirect_to admin_cached_pages_url
  end

  protected

    def set_menu
      @menu = Menus::Admin::CachedPages.new
    end

    def set_cached_pages
      conditions = params[:query] ? ['url LIKE ?', ["%#{params[:query]}%"]] : nil
      @cached_pages = @site.cached_pages.paginate :page => current_page, :conditions => conditions, :include => :references
    end

    def set_cached_page
      @cached_page = @site.cached_pages.find params[:id]
    end
end
