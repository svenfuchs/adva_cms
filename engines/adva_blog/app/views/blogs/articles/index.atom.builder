atom_feed :url => request.url do |feed|
  title = "#{@site.title} » #{@section.title}"

  title = title + " » " + t( :'adva.blog.feeds.category', :category => @category.title ) if @category
  title = title + " » " + t( :'adva.blog.feeds.tags', :tags => @tags.join(', '), :count => @tags.size ) if @tags.present?

  feed.title title
  feed.updated @articles.first ? @articles.first.updated_at : Time.now.utc

  @articles.each do |article|
    url = show_url(article)
    feed.entry article, :url => url do |entry|
      entry.title article.title
      entry.content article.body_html, :type => 'html'
      entry.author do |author|
        author.name article.author_name
        author.email article.author_email
      end
    end
  end
end