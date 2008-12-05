module EventsHelper
  def collection_title(category=nil, tags=nil)
    title = []
    title << "at #{calendar_timespan.strftime('%B %Y')}" if calendar_timespan
    title << "in #{category.title}" if category
    title << "tagged #{tags.to_sentence}" if tags
    'Events ' + title.join(', ') unless title.empty?
  end

  def calendar_timespan
    @timespan[0] if @timespan
  end
  
  def link_to_event(event)
    link_to event.title, event_url(event.section, event.permalink)
  end
end