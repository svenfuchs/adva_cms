ActionController::Routing::Routes.draw do |map|
  map.resources :newsletters, :controller => "admin/newsletters",
                              :path_prefix => "admin/sites/:site_id",
                              :name_prefix => "admin_adva_"

  map.resources :issues, :controller => "admin/issues",
                         :path_prefix => "admin/sites/:site_id/newsletters/:newsletter_id",
                         :name_prefix => "admin_adva_"

  map.resources :deleted_issues, :controller => "admin/deleted_issues",
                         :path_prefix => "admin/sites/:site_id",
                         :name_prefix => "admin_adva_"

  map.resources :subscriptions, :controller => "admin/newsletter_subscriptions",
                         :path_prefix => "admin/sites/:site_id/newsletters/:newsletter_id",
                         :name_prefix => "admin_adva_"

  map.resource :delivery, :controller => "admin/issue_delivery",
                         :path_prefix => "admin/sites/:site_id/newsletters/:newsletter_id/issues/:issue_id",
                         :name_prefix => "admin_adva_"
end
