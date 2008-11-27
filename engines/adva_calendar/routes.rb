
with_options :controller => 'events', :action => 'show', :requirements => { :method => :get } do |event|
  event.event "events/:section_id/:id"
end

with_options :controller => 'events', :action => 'index', :requirements => { :method => :get } do |event|
  event.events "events/:section_id/:year/:month"
  event.event_category "events/:section_id/categories/:category_id"
  event.formatted_events "events/:section_id.:format"
end


map.resources :events, :controller  => 'admin/events',
                       :path_prefix => 'admin/sites/:site_id/sections/:section_id',
                       :name_prefix => 'admin_'