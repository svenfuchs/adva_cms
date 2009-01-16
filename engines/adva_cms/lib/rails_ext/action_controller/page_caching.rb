ActionController::Base.class_eval do 
  def expire_pages(pages)
    pages.each { |page| expire_page(page.url) }
    CachedPage.expire_pages(pages)
  end

  def expire_site_page_cache
    cache_dir = page_cache_directory
    if cache_dir.gsub('/', '') =~ /public$/ 
      # TODO can not simply kill the whole cache dir unless in multisite mode
      # this misses assets as stylesheets from themes though because they are
      # not referenced as cached, yet
      expire_pages CachedPage.find_all_by_site_id(@site.id)
    else
      @site.cached_pages.delete_all
      Pathname.new(cache_dir).rmtree rescue Errno::ENOENT
    end
    
    # expire asset_tag_helper file_exist_cache so that assets will be re-cached
    ActionController::Base.reset_file_exist_cache!
    ActionView::Base.reset_file_exist_cache!
  end
end