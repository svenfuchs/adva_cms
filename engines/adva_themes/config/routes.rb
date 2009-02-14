ActionController::Routing::Routes.draw do |map|
  # map.connect 'themes/:theme_id/:type/*file',
  #              :controller => 'theme',
  #              :action => 'file',
  #              :requirements => { :type => /stylesheets|javascripts|images/ }
  
  map.resources :themes,          :controller  => 'admin/themes',
                                  :path_prefix => 'admin/sites/:site_id',
                                  :name_prefix => 'admin_',
                                  :collection  => { :import => :any },
                                  :member      => { :export => :get }

  map.admin_site_selected_themes  'admin/sites/:site_id/themes/selected',
                                  :controller   => 'admin/themes',
                                  :action       => 'select',
                                  :conditions   => { :method => :post }

  map.admin_site_selected_theme   'admin/sites/:site_id/themes/selected/:id',
                                  :controller   => 'admin/themes',
                                  :action       => 'unselect',
                                  :conditions   => { :method => :delete }

  map.resources :files,           :controller  => 'admin/theme_files',
                                  :path_prefix => 'admin/sites/:site_id/themes/:theme_id',
                                  :name_prefix => 'admin_theme_',
                                  :collection  => { :import => :get, :upload => :post }
end