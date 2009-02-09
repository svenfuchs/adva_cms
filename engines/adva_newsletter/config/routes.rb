ActionController::Routing::Routes.draw do |map|
  map.resources :newsletters, :controller => "admin/newsletters",
                              :path_prefix => "admin/sites/:site_id",
                              :name_prefix => "admin_"

  map.resources :issues, :controller => "admin/issues",
                         :path_prefix => "admin/sites/:site_id/newsletters/:newsletter_id",
                         :name_prefix => "admin_"

  map.resources :deleted_issues, :controller => "admin/deleted_issues",
                         :path_prefix => "admin/sites/:site_id",
                         :name_prefix => "admin_"

  #TODO: needs namespace when some other engine start using subscriptions
  # or own method like merb slice is using method silce_url(), so it looks we need nice new feature to Rails as well
  map.resources :subscriptions, :controller => "admin/newsletter_subscriptions",
                         :path_prefix => "admin/sites/:site_id/newsletters/:newsletter_id",
                         :name_prefix => "admin_"

  map.resource :delivery, :controller => "admin/issue_delivery",
                         :path_prefix => "admin/sites/:site_id/newsletters/:newsletter_id/issues/:issue_id",
                         :name_prefix => "admin_"
end