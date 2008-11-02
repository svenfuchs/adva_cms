class SectionSweeper < PageCacheTagging::Sweeper
  observe Section

  def after_save(section)
    expire_cached_pages_by_section(section)
  end

  alias after_destroy after_save
end