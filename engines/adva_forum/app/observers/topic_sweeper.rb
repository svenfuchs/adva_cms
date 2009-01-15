class TopicSweeper < CacheReferences::Sweeper
  observe Topic
  
  def after_save(topic)
    if topic.owner.is_a?(Board)
      expire_cached_pages_by_reference(topic.board)
    else
      expire_cached_pages_by_section(topic.section)
    end
  end

  alias after_destroy after_save
end