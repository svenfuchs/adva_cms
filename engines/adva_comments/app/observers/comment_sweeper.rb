class CommentSweeper < CacheReferences::Sweeper
  observe Comment

  def after_save(comment)
    expire_cached_pages_by_reference(comment.commentable)
  end

  alias after_destroy after_save
end