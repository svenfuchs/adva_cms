map.resources :newsletters, :controller => 'admin/newsletters',
                            :path_prefix => 'admin/sites/:site_id',
                            :name_prefix => 'admin_'

map.resources :issues, :controller => 'admin/issues',
                       :path_prefix => 'admin/sites/:site_id',
                       :name_prefix => 'admin_'
