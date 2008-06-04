map.login 'login',         :controller => 'session', 
                           :action => 'new'                                          
map.logout 'logout',       :controller => 'session', 
                           :action => 'destroy',
                           :conditions => { :method => :delete }
                           
map.resource :session,     :controller => 'session'
map.resource :password,    :controller => 'password'
map.resource :account,     :controller => 'account',
                           :member => { :verify => :get }
                           
map.resources :users,      :path_prefix => "admin", 
                           :name_prefix => "admin_",
                           :namespace   => "admin/"
                           
map.resources :users,      :path_prefix => "admin/sites/:site_id", 
                           :name_prefix => "admin_site_",
                           :namespace   => "admin/"
                         
# map.resources :roles,      :path_prefix => "admin/sites/:site_id/users/:user_id", 
#                            :name_prefix => "admin_user_",
#                            :namespace   => "admin/"
                         
