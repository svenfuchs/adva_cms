ActionController::Routing::Routes.draw do |map|
  map.connect 'themes/:theme_id/:type/*file',
               :controller => 'theme',
               :action => 'file',
               :requirements => { :type => /stylesheets|javascripts|images/ }
end