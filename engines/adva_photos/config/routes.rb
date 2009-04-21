ActionController::Routing::Routes.draw do |map|
  # Frontend routes
  map.with_options :controller => 'albums', :conditions => { :method => :get } do |r|
    r.album           "albums/:section_id",
                      :action => 'index'
                          
    r.album_set       "albums/:section_id/sets/:set_id.:format",
                      :action => 'index'
                      
    r.album_tag       "albums/:section_id/tags/:tags.:format",
                      :action => 'index'

    r.photo           "albums/:section_id/photos/:photo_id.:format",
                      :action => "show"
                      
    r.album_comments  'albums/:section_id/comments.:format',
                      :action => "comments"
  end

  # Backend routes
  map.resources :photos, :path_prefix => "admin/sites/:site_id/sections/:section_id",
                         :name_prefix => "admin_",
                         :namespace   => "admin/"


  map.resources :sets,   :path_prefix => "admin/sites/:site_id/sections/:section_id",
                         :name_prefix => "admin_",
                         :namespace   => "admin/"

  map.connect            'admin/sites/:site_id/sections/:section_id/sets',
                         :controller   => 'admin/sets',
                         :action       => 'update_all',
                         :conditions   => { :method => :put }

end