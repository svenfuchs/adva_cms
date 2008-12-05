
with_options :controller => 'events', :action => 'show', :requirements => { :method => :get } do |event|
  event.calendar_event "/calendars/:section_id/:id"
  event.formatted_calendar_event "/calendars/:section_id/:id.:format"
end

with_options :controller => 'events', :action => 'index', :requirements => { :method => :get } do |event|
  event.calendar_events "calendars/:section_id/:year/:month/:day", :year => nil, :month => nil, :day => nil,
    :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }
  event.formatted_calendar_events "calendars/:section_id.:format"

  event.calendar_events_category "calendars/:section_id/categories/:category_id"
  event.formatted_calendar_events_category "calendars/:section_id/categories/:category_id.:format"
end


map.resources :calendar_events, :controller  => 'admin/events',
                                :path_prefix => 'admin/sites/:site_id/sections/:section_id',
                                :name_prefix => 'admin_', :as => 'events'