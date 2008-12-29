

with_options :controller => 'events', :action => 'index', :conditions => { :method => :get } do |event|
  event.calendar_events "calendars/:section_id/events/:year/:month/:day", :year => nil, :month => nil, :day => nil,
    :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }
  event.connect "calendars/:section_id"
  event.formatted_calendar_events "calendars/:section_id.:format"

  event.calendar_category "calendars/:section_id/categories/:category_id"
  event.formatted_calendar_category "calendars/:section_id/categories/:category_id.:format"
  
  event.calendar_tag 'calendars/:section_id/tags/:tags', :conditions => { :method => :get }
end

map.calendar_event "calendars/:section_id/event/:id", :controller => 'events', :action => 'show', :conditions => { :method => :get }
map.formatted_calendar_event "calendars/:section_id/event/:id.:format", :controller => 'events', :action => 'show', :conditions => { :method => :get }

map.resources :calendar_events, :controller  => 'admin/events',
                                :path_prefix => 'admin/sites/:site_id/sections/:section_id',
                                :name_prefix => 'admin_', :as => 'events'