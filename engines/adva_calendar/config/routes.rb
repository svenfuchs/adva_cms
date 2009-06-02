ActionController::Routing::Routes.draw do |map|
  map.with_options :conditions => { :method => :get } do |m|

    m.calendar_events             "calendars/:section_id/:year/:month/:day",
                                  :controller => 'calendar_events',
                                  :action => 'index',
                                  :year => nil, :month => nil, :day => nil,
                                  :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }

    m.calendar                    "calendars/:section_id",
                                  :controller => 'calendar_events',
                                  :action => 'index'

    m.formatted_calendar_events   "calendars/:section_id.:format",
                                  :controller => 'calendar_events',
                                  :action => 'index'

    m.connect                     "calendars/:section_id/:year/:month.:format",
                                  :controller => 'calendar_events',
                                  :action => 'index',
                                  :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }

    m.calendar_category           "calendars/:section_id/categories/:category_id",
                                  :controller => 'calendar_events',
                                  :action => 'index'

    m.formatted_calendar_category "calendars/:section_id/categories/:category_id.:format",
                                  :controller => 'calendar_events',
                                  :action => 'index'

    m.calendar_tag                'calendars/:section_id/tags/:tags',
                                  :controller => 'calendar_events',
                                  :action => 'index'

    m.calendar_event              "calendars/:section_id/event/:permalink",
                                  :controller => 'calendar_events',
                                  :action => 'show'

    m.formatted_calendar_event    "calendars/:section_id/event/:permalink.:format",
                                  :controller => 'calendar_events',
                                  :action => 'show'
  end

  map.resources :calendar_events, :controller  => 'admin/calendar_events',
                                  :path_prefix => 'admin/sites/:site_id/sections/:section_id',
                                  :name_prefix => 'admin_',
                                  :as => 'events'
end