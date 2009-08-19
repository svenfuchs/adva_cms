class SectionSweeper < CacheReferences::Sweeper
  observe Section

  def after_create(section)
    expire_cached_pages_by_site(section.site)
  end

  def after_save(section)
    expire_cached_pages_by_section(section)
  end

  alias after_destroy after_create
end
