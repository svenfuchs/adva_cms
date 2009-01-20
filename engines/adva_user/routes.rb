map.login 'login',         :controller => 'session',
                           :action => 'new'

map.logout 'logout',       :controller => 'session',
                           :action => 'destroy'

map.signup 'signup',       :controller => 'user',
                           :action => 'new'

map.resource :session,     :controller => 'session'
map.resource :password,    :controller => 'password'
map.resource :user,        :controller => 'user',
                           :member => { :verify => :get }

map.resources :users,      :path_prefix => "admin",
                           :name_prefix => "admin_",
                           :namespace   => "admin/"

map.resources :users,      :path_prefix => "admin/sites/:site_id",
                           :name_prefix => "admin_site_",
                           :namespace   => "admin/"

map.user_roles             'users/:user_id/roles.:format',
                           :controller  => 'roles'

map.user_object_roles      'users/:user_id/roles/:object_type/:object_id.:format',
                           :controller  => 'roles'

