class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment

  def after_save(comment)
    purge_cache_by(comment.commentable)
    
    # if comment.is_a?(Post)
    #   topic = comment.commentable
    #   purge_cache_by(topic.comments_counter)
    #   purge_cache_by(topic.owner.comments_counter)
    # end
  end

  alias after_destroy after_save
end