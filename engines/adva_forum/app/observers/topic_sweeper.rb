class TopicSweeper < CacheReferences::Sweeper
  observe Topic
  
  def after_save(topic)
    if topic.owner.is_a?(Board)
      expire_cached_pages_by_reference(topic.owner)
      expire_cached_pages_by_reference(topic.owner.topics_counter)
    else
      expire_cached_pages_by_section(topic.owner)
    end
    expire_cached_pages_by_reference(topic.section.topics_counter)
    expire_cached_pages_by_reference(topic)
  end

  alias after_destroy after_save
end