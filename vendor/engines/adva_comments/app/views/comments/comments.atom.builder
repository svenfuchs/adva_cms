atom_feed :url => request.url do |feed|
  feed.title comments_feed_title
  feed.updated @comments.empty? ? Time.now : @comments.first.created_at

  @comments.each do |comment|
    url = content_url(comment.commentable, :anchor => dom_id(comment))
    feed.entry comment, :url => url do |entry|
      entry.title "Comment on '#{comment.commentable.title}' by #{comment.author_name}"
      entry.content comment.body_html, :type => 'html'
      entry.author do |author|
        author.name comment.author_name
        author.email comment.author_email
      end
    end
  end
end