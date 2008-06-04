class SectionSweeper < PageCacheTagging::Sweeper
  observe Section

  def after_save(record)
    expire_cached_pages_by_section record
  end

  alias after_destroy after_save
end