ActionController::Routing::Routes.draw do |map|
  map.tracker "trackers/:section_id",
              :controller => "tracker",
              :action     => "show",
              :conditions => { :method => :get }

  map.resources :projects, :path_prefix => "trackers/:section_id"
  map.resources :tickets,  :path_prefix => "trackers/:section_id/projects/:project_id"

# Admin routes
  map.resources :trackers, :controller  => "admin/tracker",
                           :path_prefix => "admin/sites/:site_id/sections/:section_id",
                           :name_prefix => "admin_"

  map.resources :projects, :controller  => "admin/projects",
                           :path_prefix => "admin/sites/:site_id/sections/:section_id",
                           :name_prefix => "admin_"
end
