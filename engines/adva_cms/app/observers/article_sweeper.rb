class ArticleSweeper < CacheReferences::Sweeper
  observe Article
  
  # def after_create(article)
  #   expire_cached_pages_by_section(article.section)
  # end

  def before_save(article)
    record = article.new_record? ? article.section : article
    expire_cached_pages_by_reference(record)
  end
  
  # def after_save(article)
  #   if article.section.articles.count == 1
  #     expire_cached_pages_by_reference article.section
  #   end
  #   expire_cached_pages_by_reference article
  # end

  alias after_destroy before_save
end
