class CalendarEventSweeper < CacheReferences::Sweeper
  observe CalendarEvent

  def before_save(record)
    if record.new_record? or record.just_published?
      expire_cached_pages_by_section(record.section)
    else
      expire_cached_pages_by_reference(record)
    end
  end

  alias after_destroy before_save
end