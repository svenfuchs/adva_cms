map.connect ':type/themes/:theme_id/*file', 
             :controller => 'theme', 
             :action => 'file',
             :requirements => { :type => /stylesheets|javascripts|images/ }
