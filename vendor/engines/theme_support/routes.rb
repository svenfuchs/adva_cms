map.connect ":type/themes/:subdir/:theme_id/*file", 
              :controller => 'theme', 
              :action => 'file',
              :requirements => { :type => /(images|stylesheets|javascripts)/ }

# map.connect ":type/themes/:theme_id/*file", ...

# options = { :controller => 'theme', 
#             :action => 'file',
#             :requirements => { :file => /(preview.png)/ } }
# 
# map.connect ":type/themes/:subdir/:theme_id/:file", options
# map.connect ":type/themes/:theme_id/:file", options


