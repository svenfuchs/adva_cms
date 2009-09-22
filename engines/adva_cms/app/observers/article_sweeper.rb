class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  def before_save(article)
    if article.new_record? or article.just_published?
      purge_cache_by(article.section)
    else
      purge_cache_by(article)
    end
  end

  alias after_destroy before_save
end
