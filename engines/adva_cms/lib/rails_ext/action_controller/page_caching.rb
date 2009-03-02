ActionController::Base.class_eval do 
  def expire_pages(pages)
    pages.each { |page| expire_page(page.url) if page.url }
    CachedPage.expire_pages(pages)
  end

  def expire_site_page_cache
    # FIXME 
    # We can not simply kill the whole cache dir.
    # The following misses assets (like stylesheets) from themes though 
    # because they are not referenced as cached, yet. Do we need to expire
    # these assets at all though?
    expire_pages CachedPage.find_all_by_site_id(@site.id)

    # cache_dir = page_cache_directory
    # if cache_dir.gsub('/', '') =~ /public$/ 
    #   expire_pages CachedPage.find_all_by_site_id(@site.id)
    # else
    #   @site.cached_pages.delete_all
    #   Pathname.new(cache_dir).rmtree rescue Errno::ENOENT
    # end
  end
end