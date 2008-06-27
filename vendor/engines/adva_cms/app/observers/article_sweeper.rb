class ArticleSweeper < PageCacheTagging::Sweeper
  observe Article
  
  def before_save(article)
    if article.new_record?
      expire_cached_pages_by_reference article.section
    else
      expire_cached_pages_by_reference article
    end
  end

  # def after_save(article)
  #   if article.section.articles.count == 1
  #     expire_cached_pages_by_reference article.section
  #   end
  #   expire_cached_pages_by_reference article
  # end

  alias after_destroy before_save
end