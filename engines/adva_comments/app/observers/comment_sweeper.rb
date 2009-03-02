class CommentSweeper < CacheReferences::Sweeper
  observe Comment

  def after_save(comment)
    expire_cached_pages_by_reference(comment.commentable)
    
    # if comment.is_a?(Post)
    #   topic = comment.commentable
    #   expire_cached_pages_by_reference(topic.comments_counter)
    #   expire_cached_pages_by_reference(topic.owner.comments_counter)
    # end
  end

  alias after_destroy after_save
end