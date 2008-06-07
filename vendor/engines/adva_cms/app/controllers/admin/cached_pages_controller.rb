class Admin::CachedPagesController < Admin::BaseController
  helper :cached_pages
  
  before_filter :set_cached_pages, :only => :index
  before_filter :set_cached_page, :only => :destroy
  
  layout 'admin', :except => [:destroy]
  
  guards_permissions :site, :manage => [:index, :destroy, :clear], :only => :index

  def destroy
    self.class.expire_page @cached_page.url
    @cached_page.destroy
    respond_to {|format| format.js }
  end
  
  def clear
    @site.cached_pages.each { |page| self.class.expire_page page.url }
    @site.cached_pages.delete_all
    
    flash[:notice] = 'The cache has been cleared.'
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