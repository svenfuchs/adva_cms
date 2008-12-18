class BlogCell < Cell::Base
  def recent_articles
    @articles = Article.all :limit => 5
    nil
  end
end