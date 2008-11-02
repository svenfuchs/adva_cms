class ArticleSweeper < PageCacheTagging::Sweeper
  observe Article

  def before_save(article)
    expire_cached_pages_by_reference(article.new_record? ? article.section : article)
  end

  # def after_save(article)
  #   if article.section.articles.count == 1
  #     expire_cached_pages_by_reference article.section
  #   end
  #   expire_cached_pages_by_reference article
  # end

  alias after_destroy before_save
end