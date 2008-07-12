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


map.with_options :controller => 'theme', :action => 'file' do |m| 
  m.connect ':type/:theme_id/*file',       :type => /stylesheets|javascripts|images/
  m.css    'stylesheets/:theme_id/:path.:ext', :type => 'stylesheets'
  m.js     'javascripts/:theme_id/:path.:ext', :type => 'javascripts'
  m.images 'images/:theme_id/:path.:ext',      :type => 'images'
end