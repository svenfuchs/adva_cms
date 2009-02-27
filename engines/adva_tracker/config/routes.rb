ActionController::Routing::Routes.draw do |map|
  map.resources :projects,    :controller => "admin/projects",
                              :path_prefix => "admin/sites/:site_id/sections/:section_id",
                              :name_prefix => "admin_"
  map.resources :trackers,    :controller  => "admin/tracker",
                              :path_prefix => "admin/sites/:site_id/sections/:section_id",
                              :name_prefix => "admin_"
  # map.resources :tickets,   :controller  => "admin/tickets",
                            # :path_prefix => "admin/sites/:site_id/sections/:section_id",
                            # :name_prefix => "admin_"
end
