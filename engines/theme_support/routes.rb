# map.connect ':type/themes/:theme_id/*file',
#              :controller => 'theme',
#              :action => 'file',
#              :requirements => { :type => /stylesheets|javascripts|images/ }

map.connect 'themes/:theme_id/:type/*file',
             :controller => 'theme',
             :action => 'file',
             :requirements => { :type => /stylesheets|javascripts|images/ }
