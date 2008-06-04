class CategorySweeper < PageCacheTagging::Sweeper
  observe Category

  def after_save(record)
    expire_cached_pages_by_section record.section
  end

  alias after_destroy after_save
end