module CalendarEventsHelper
  def collection_title(category=nil, tags=nil)
    title = []
    title << current_timespan.first.strftime(current_timespan_format||t(:'adva.calendar.titles.formats.year_month')) if current_timespan.first.present?
    title << t(:'adva.calendar.titles.in_category', :title => category.title) if category
    title << t(:'adva.calendar.titles.tagged', :tags => tags.to_sentence) if tags
    t(:'adva.calendar.titles.events') + ' ' + title.join(', ') if title.present?
  end
  
  def link_to_event(event)
    link_to event.title, calendar_event_url(event.section_id, event.permalink)
  end

  # returns an array with start and end date
  def event_dates_from_to(event)
    if event.all_day?
      if event.end_date.blank? or event.start_date.to_date == event.end_date.to_date
        return [event.start_date.beginning_of_day]
      else
        return [event.start_date.beginning_of_day, event.end_date.end_of_day]
      end
    else
      return [event.start_date, event.end_date].compact
    end
  end
end