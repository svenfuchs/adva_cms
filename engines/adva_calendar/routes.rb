
with_options :controller => 'events', :action => 'show', :requirements => { :method => :get } do |event|
end

with_options :controller => 'events', :action => 'index', :requirements => { :method => :get } do |event|
  event.events "calendars/:section_id/:year/:month/:day", :year => nil, :month => nil, :day => nil,
    :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }
  event.formatted_events "calendars/:section_id.:format"

  event.events_category "calendars/:section_id/categories/:category_id"
  event.formatted_events_category "events/:section_id/categories/:category_id.:format"
  
  event.event "/calendars/:section_id/:id", :action => 'show'
  event.formatted_event "/calendars/:section_id/:id.:format", :action => 'show'
end


map.resources :calendar_events, :controller  => 'admin/events',
                                :path_prefix => 'admin/sites/:site_id/sections/:section_id',
                                :name_prefix => 'admin_', :as => 'events'