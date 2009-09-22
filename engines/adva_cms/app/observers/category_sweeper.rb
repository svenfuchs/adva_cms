class CategorySweeper < ActionController::Caching::Sweeper
  observe Category

  def after_save(category)
      purge_cache_by(category.section)
  end

  alias after_destroy after_save
end
