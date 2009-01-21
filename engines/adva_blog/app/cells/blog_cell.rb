class BlogCell < Cell::Base
  
  tracks_cache_references :recent_articles, :track => ['@articles']
  
  def recent_articles
    options = @opts.symbolize_keys
    
    @count = options[:count] || 5
    @articles = Article.all(:limit => @count, :order => "published_at DESC")

    nil
  end
end