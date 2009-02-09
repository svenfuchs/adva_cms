ActionController::Routing::Routes.draw do |map|
  map.admin_assets_bucket  'admin/sites/:site_id/assets/bucket',
                           :controller => 'admin/assets_bucket',
                           :action     => 'create',
                           :conditions => { :method => :post }

  map.connect              'admin/sites/:site_id/assets/bucket',
                           :controller => 'admin/assets_bucket',
                           :action     => 'destroy',
                           :conditions => { :method => :delete }

  map.resources :assets,   :controller  => 'admin/assets',
                           :path_prefix => 'admin/sites/:site_id',
                           :name_prefix => 'admin_'

  map.admin_asset_contents 'admin/sites/:site_id/assets/:asset_id/contents',
                           :controller  => 'admin/asset_contents',
                           :action      => 'create',
                           :conditions  => {:method => :post}

  map.admin_asset_content  'admin/sites/:site_id/assets/:asset_id/contents/:id',
                           :controller  => 'admin/asset_contents',
                           :action      => 'destroy',
                           :conditions  => {:method => :delete}

end