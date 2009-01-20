class BlogCell < Cell::Base
  def recent_articles
    options = @opts.symbolize_keys
    
    @count = options[:count] || 5
    @articles = Article.all(:limit => @count, :order => "published_at DESC")
    
    nil
  end
end