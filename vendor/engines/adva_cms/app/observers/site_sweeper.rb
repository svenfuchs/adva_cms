class SiteSweeper < PageCacheTagging::Sweeper
  observe Site

  def after_save(record)
    expire_cached_pages_by_site record
  end

  alias after_destroy after_save
end