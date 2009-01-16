class CategorySweeper < CacheReferences::Sweeper
  observe Category

  def after_save(category)
    expire_cached_pages_by_section(category.section)
  end

  alias after_destroy after_save
end
