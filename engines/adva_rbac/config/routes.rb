ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'roles' do |r|
    r.user_roles        'users/:user_id/roles.:format'
    r.user_object_roles 'users/:user_id/roles/:object_type/:object_id.:format'
  end
end