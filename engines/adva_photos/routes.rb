# Frontend routes
with_options :controller => 'albums', :action => 'index', :requirements => { :method => :get } do |album|

  album.album                   "albums/:section_id"
  album.album_set               "albums/:section_id/sets/:set_id"
  album.album_tag               "albums/:section_id/tags/:tags"

  album.formatted_album         "albums/:section_id.:format"
  album.formatted_album_set     "albums/:section_id/sets/:set_id.:format"
  album.formatted_album_tag     "albums/:section_id/tags/:tags.:format"
end

map.photo                       "albums/:section_id/photos/:photo_id",
                                :controller   => 'albums',
                                :action       => "show",
                                :requirements => { :method => :get }

map.formatted_album_comments    'albums/:section_id/comments.:format',
                                :controller   => 'albums',
                                :action       => "comments",
                                :requirements => { :method => :get }

map.formatted_album_photo_comments "albums/:section_id/photos/:photo_id.:format",
                                :controller   => 'albums',
                                :action       => "comments",
                                :requirements => { :method => :get }

# Backend routes
map.resources :photos, :path_prefix => "admin/sites/:site_id/sections/:section_id",
                       :name_prefix => "admin_",
                       :namespace   => "admin/"


map.resources :sets,   :path_prefix => "admin/sites/:site_id/sections/:section_id",
                       :name_prefix => "admin_",
                       :namespace   => "admin/"