ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'wiki', :action => 'show', :conditions => { :method => :get } do |wiki|
    wiki.wiki                     'wikis/:section_id.:format'
    wiki.wikipage_rev             'wikis/:section_id/wikipages/:id/rev/:version'
    wiki.wikipage_diff            'wikis/:section_id/wikipages/:id/diff/:diff_version', :action => 'diff'
    wiki.wikipage_rev_diff        'wikis/:section_id/wikipages/:id/rev/:version/diff/:diff_version', :action => 'diff'
  end

  map.with_options :controller => 'wiki', :action => 'index', :conditions => { :method => :get } do |wiki|
    wiki.wiki_category            'wikis/:section_id/categories/:category_id.:format'
    wiki.wiki_tag                 'wikis/:section_id/tags/:tags.:format'
  end

  map.resources :wikipages,       :controller  => 'wiki',
                                  :path_prefix => 'wikis/:section_id'

  map.wiki_comments               'wikis/:section_id/comments.:format',
                                  :controller   => 'wiki',
                                  :action       => 'comments',
                                  :conditions   => { :method => :get }

  map.wikipage_comments           'wikis/:section_id/wikipages/:id/comments.:format',
                                  :controller   => 'wiki',
                                  :action       => 'comments',
                                  :conditions   => { :method => :get }

  map.resources :wikipages,       :path_prefix  => 'admin/sites/:site_id/sections/:section_id',
                                  :name_prefix  => 'admin_',
                                  :namespace    => 'admin/'
end