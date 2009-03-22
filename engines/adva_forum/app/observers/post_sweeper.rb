class PostSweeper < CacheReferences::Sweeper
  observe Post

  def after_save(post)
    expire_cached_pages_by_reference(post.topic)
    
    expire_cached_pages_by_reference(post.topic.posts_counter)
    expire_cached_pages_by_reference(post.topic.board.posts_counter) if post.topic.board
    expire_cached_pages_by_reference(post.topic.section.posts_counter)
  end

  alias after_destroy after_save
end