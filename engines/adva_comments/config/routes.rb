ActionController::Routing::Routes.draw do |map|
  map.resources :comments, :collection => { :preview => :post }

  map.resources :comments, :path_prefix => "admin/sites/:site_id",
                           :controller  => 'comments',
                           :name_prefix => "admin_site_",
                           :namespace   => "admin/"
end