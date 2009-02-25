ActionController::Routing::Routes.draw do |map|
  map.with_options :conditions => { :method => :get } do |m|

    m.calendar_events             "calendars/:section_id/:year/:month/:day",
                                  :controller => 'events',
                                  :action => 'index',
                                  :year => nil, :month => nil, :day => nil,
                                  :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }

    m.connect                     "calendars/:section_id",
                                  :controller => 'events',
                                  :action => 'index'

    m.formatted_calendar_events   "calendars/:section_id.:format",
                                  :controller => 'events',
                                  :action => 'index'

    # m.connect                     "calendars/:section_id/:year/:month.:format",
    #                               :controller => 'events',
    #                               :action => 'index',
    #                               :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }

    m.calendar_category           "calendars/:section_id/categories/:category_id",
                                  :controller => 'events',
                                  :action => 'index'

    m.formatted_calendar_category "calendars/:section_id/categories/:category_id.:format",
                                  :controller => 'events',
                                  :action => 'index'

    m.calendar_tag                'calendars/:section_id/tags/:tags',
                                  :controller => 'events',
                                  :action => 'index'

    m.calendar_event              "calendars/:section_id/event/:permalink",
                                  :controller => 'events',
                                  :action => 'show'

    m.formatted_calendar_event    "calendars/:section_id/event/:permalink.:format",
                                  :controller => 'events',
                                  :action => 'show'
  end

  map.resources :calendar_events, :controller  => 'admin/events',
                                  :path_prefix => 'admin/sites/:site_id/sections/:section_id',
                                  :name_prefix => 'admin_',
                                  :as => 'events'
end