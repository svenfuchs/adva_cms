require 'routing_filter'
require 'routing_filter/locale'

ActionController::Routing::Routes.draw do |map|
  RoutingFilter::Locale.include_default_locale = false

  map.filter 'locale'
  map.filter 'categories' # TODO fix: around_filter seems to call filters in reverse order
  map.filter 'sets'       # TODO fix: around_filter seems to call filters in reverse order
  map.filter 'section_root'
  map.filter 'section_paths'
  map.filter 'pagination'

  map.page                             'pages/:section_id',
                                       :controller   => 'articles',
                                       :action       => "index",
                                       :conditions => { :method => :get }

  map.page_article                     'pages/:section_id/articles/:permalink',
                                       :controller   => 'articles',
                                       :action       => "show",
                                       :conditions => { :method => :get }

  map.formatted_page_comments          'pages/:section_id/comments.:format',
                                       :controller   => 'articles',
                                       :action       => "comments",
                                       :conditions => { :method => :get }

  map.formatted_page_article_comments  'pages/:section_id/articles/:permalink.:format',  # FIXME can we remove this one?
                                       :controller   => 'articles',
                                       :action       => "comments",
                                       :conditions => { :method => :get }


  map.connect 'admin',            :controller   => 'admin/sites',
                                  :action       => 'index',
                                  :conditions => { :method => :get }

  map.resources :sites,           :controller   => 'admin/sites',
                                  :path_prefix  => 'admin',
                                  :name_prefix  => 'admin_'

  map.resources :sections,        :controller  => 'admin/sections',
                                  :path_prefix => 'admin/sites/:site_id',
                                  :name_prefix => 'admin_'

  # the resources :collection option does not allow to put to the collection url
  # so we connect another route, which seems slightly more restful
  map.connect                     'admin/sites/:site_id/sections',
                                  :controller   => 'admin/sections',
                                  :action       => 'update_all',
                                  :conditions   => { :method => :put }

  map.resources :themes,          :controller  => 'admin/themes',
                                  :path_prefix => 'admin/sites/:site_id',
                                  :name_prefix => 'admin_',
                                  :collection  => { :import => :any },
                                  :member      => { :export => :get }

  map.admin_site_selected_themes  'admin/sites/:site_id/themes/selected',
                                  :controller   => 'admin/themes',
                                  :action       => 'select',
                                  :conditions   => { :method => :post }

  map.admin_site_selected_theme   'admin/sites/:site_id/themes/selected/:id',
                                  :controller   => 'admin/themes',
                                  :action       => 'unselect',
                                  :conditions   => { :method => :delete }

  map.connect 'cached_pages',     :controller  => 'admin/cached_pages',
                                  :action      => 'clear',
                                  :path_prefix => 'admin/sites/:site_id',
                                  :name_prefix => 'admin_',
                                  :conditions  => { :method => :delete }

  map.resources :cached_pages,    :controller  => 'admin/cached_pages', # TODO map manually? we only use some of these
                                  :path_prefix => 'admin/sites/:site_id',
                                  :name_prefix => 'admin_'

  map.resources :plugins,         :controller  => 'admin/plugins', # TODO map manually? we only use some of these
                                  :path_prefix => 'admin/sites/:site_id',
                                  :name_prefix => 'admin_'

  map.resources :files,           :controller  => 'admin/theme_files',
                                  :path_prefix => 'admin/sites/:site_id/themes/:theme_id',
                                  :name_prefix => 'admin_theme_',
                                  :collection  => { :import => :any }

  map.resources :articles,        :path_prefix => "admin/sites/:site_id/sections/:section_id",
                                  :name_prefix => "admin_",
                                  :namespace   => "admin/"

  map.connect                     'admin/sites/:site_id/sections/:section_id/articles',
                                  :controller   => 'admin/articles',
                                  :action       => 'update_all',
                                  :conditions   => { :method => :put }

  map.resources :categories,      :path_prefix => "admin/sites/:site_id/sections/:section_id",
                                  :name_prefix => "admin_",
                                  :namespace   => "admin/"

  map.connect                     'admin/sites/:site_id/sections/:section_id/categories',
                                  :controller   => 'admin/categories',
                                  :action       => 'update_all',
                                  :conditions   => { :method => :put }

  map.connect                     'admin/cells.xml', :controller => 'admin/cells', :action => 'index', :format => 'xml'

  map.install 'admin/install',    :controller   => 'admin/install'
  map.root                        :controller   => 'admin/install' # will kick in when no site is installed, yet
end