module EventsHelper
  def collection_title(category=nil, tags=nil)
    title = []
    title << current_timespan.first.strftime(current_timespan_format||t(:'adva.calendar.titles.formats.year_month')) unless current_timespan.first.blank?
    title << t(:'adva.calendar.titles.in_category', :title => category.title) if category
    title << t(:'adva.calendar.titles.tagged', :tags => tags.to_sentence) if tags
    t(:'adva.calendar.titles.events') + ' ' + title.join(', ') unless title.empty?
  end
  
  def link_to_event(event)
    link_to event.title, calendar_event_url(event.section_id, event.permalink)
  end
end