module EventsHelper
  def collection_title(category=nil, tags=nil)
    title = []
    title << current_timespan.first.strftime(current_timespan_format||t(:'adva.calendar.titles.formats.year_month')) unless current_timespan.first.blank?
    title << "in #{category.title}" if category
    title << "tagged #{tags.to_sentence}" if tags
    'Events ' + title.join(', ') unless title.empty?
  end
  
  def link_to_event(event)
    link_to event.title, calendar_event_url(event.section_id, event.permalink)
  end
end