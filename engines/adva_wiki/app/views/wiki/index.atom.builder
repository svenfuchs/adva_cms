atom_feed :url => request.url do |feed|
  title = "#{@site.title} » #{@section.title}"
  title = title + " » Category #{@category.title}" if @category
  title = title + " » #{@tags.size == 1 ? 'Tag' : 'Tags'}: #{@tags.join(', ')}" if @tags.present?
  
  feed.title title
  feed.updated @wikipages.first ? @wikipages.first.updated_at : Time.now.utc

  @wikipages.each do |wikipage|
    url = wikipage_url(wikipage)
    feed.entry wikipage, :url => url do |entry|
      entry.title wikipage.title
      entry.content wikipage.body_html, :type => 'html'
      entry.author do |author|
        author.name wikipage.author_name
        author.email wikipage.author_email
      end
    end
  end
end