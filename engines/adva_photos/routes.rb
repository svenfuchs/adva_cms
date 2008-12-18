# Frontend routes
map.album "albums/:section_id",
          :controller   => 'albums',
          :action       => "show"

# Backend routes
map.resources :photos, :path_prefix => "admin/sites/:site_id/sections/:section_id",
                       :name_prefix => "admin_",
                       :namespace   => "admin/"


map.resources :sets,   :path_prefix => "admin/sites/:site_id/sections/:section_id",
                       :name_prefix => "admin_",
                       :namespace   => "admin/"