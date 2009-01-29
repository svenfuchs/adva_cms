class SectionsCell < BaseCell
  tracks_cache_references :recent_articles, :track => ['@section', '@articles']

  has_state :recent_articles

  def recent_articles
    # TODO make these before filters
    symbolize_options!
    set_site
    set_section

    @count = @opts[:count] || 5
    @articles = with_sections_scope(Article) do
      Article.all(:limit => @count, :order => "published_at DESC")
    end

    nil
  end
end