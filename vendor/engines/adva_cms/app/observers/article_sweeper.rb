class ArticleSweeper < PageCacheTagging::Sweeper
  observe Article

  def after_save(article)
    expire_cached_pages_by_reference article
  end

  alias after_destroy after_save
end