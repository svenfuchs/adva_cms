atom_feed :url => request.url do |feed|
  title = "#{@site.title} » #{@section.title}"
  title = title + " » Category #{@category.title}" if @category
  title = title + " » #{@tags.size == 1 ? 'Tag' : 'Tags'}: #{@tags.join(', ')}" unless @tags.blank?
  
  feed.title title
  feed.updated @articles.first ? @articles.first.updated_at : Time.now.utc

  @articles.each do |article|
    url = article_url @section, article.full_permalink
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