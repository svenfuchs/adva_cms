# We need to expire all pages that reference the tag collection as a whole
# when a single new tag is created or an existing is removed (because the
# new tag needs to appear in the tagcloud).
#
# Also, when a single tagging is created or removed (i.e. an object is tagged)
# we also need to expire all pages that display that tagcloud.

class TagSweeper < CacheReferences::Sweeper
  observe Tag

  def after_save(tag)
    unless controller
      # TODO wtf. this seems to be a rails bug: stale around_filters aren't removed
      # from the filter_chain on reload in dev mode. there's been some heavy refactoring
      # on filters recently, so maybe this has been resolved in 2.1
      RAILS_DEFAULT_LOGGER.warn "RAILS BUG -- skipping stale sweeper #{self.object_id} in #{self.class.name}#after_save(tag)"
      return
    end
    expire_cached_pages_by_reference controller.site, :tag_counts

    # TODO section does not exist
    # expire_cached_pages_by_reference controller.section, :tag_counts
  end

  alias after_destroy after_save
end
