class SiteSweeper < CacheReferences::Sweeper
  observe Site

  def after_save(site)
    expire_cached_pages_by_site(site)
  end

  alias after_destroy after_save
end
