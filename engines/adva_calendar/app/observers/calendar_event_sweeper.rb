class CalendarEventSweeper < CacheReferences::Sweeper
  observe CalendarEvent

  def after_save(event)
    expire_cached_pages_by_reference event
  end

  alias after_destroy after_save
end