class BlogComponent < Components::Base
  def recent_articles(*args)
    options = args.extract_options!
    @count = options['count'] || 5
    @articles = Article.all :limit => @count
    render
  end
end