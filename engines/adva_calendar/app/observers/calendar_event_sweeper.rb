class CalendarEventSweeper < ActionController::Caching::Sweeper
  observe CalendarEvent

  def before_save(event)
    if event.new_record? or event.just_published?
      purge_cache_by(event.section)
    else
      purge_cache_by(event)
    end
  end

  alias after_destroy before_save
end