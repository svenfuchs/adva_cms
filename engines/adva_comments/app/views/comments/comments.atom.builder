atom_feed :url => request.url do |feed|
  feed.title comments_feed_title(@site, @section, @commentable)
  feed.updated @comments.present? ? @comments.first.created_at : Time.now

  @comments.each do |comment|
    url = show_url(comment.commentable, :anchor => dom_id(comment))
    feed.entry comment, :url => url do |entry|
      entry.title I18n.t(:'adva.comments.titles.comment_on_by', :on => comment.commentable.title, :by => comment.author_name)
      entry.content comment.body_html, :type => 'html'
      entry.author do |author|
        author.name comment.author_name
        author.email comment.author_email
      end
    end
  end
end