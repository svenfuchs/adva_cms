class BlogCell < BaseCell
  tracks_cache_references :recent_articles, :track => ['@section', '@articles']

  has_state :recent_articles

  def recent_articles
    # TODO make these before filters
    symbolize_options!
    set_site
    set_section

    @count = @opts[:count] || 5
    @recent_blog_articles = @section.articles.published(:limit => @count, :order => "published_at DESC")
    nil
  end
end