ActionController::Routing::Routes.draw do |map|
  map.forum           'forums/:section_id',
                      :controller   => 'forum',
                      :action       => "show",
                      :conditions   => { :method => :get }

  map.forum_board     'forums/:section_id/boards/:board_id',
                      :controller   => 'forum',
                      :action       => 'show',
                      :conditions   => { :method => :get }

  map.new_board_topic 'forums/:section_id/boards/:board_id/topics/new',
                      :controller => 'topics',
                      :action     => 'new',
                      :conditions => { :method => :get }

  map.resources :topics, :path_prefix => 'forums/:section_id', :member => { :previous => :get, :next => :get } do |topic|
    topic.resources :posts
  end


  # ADMIN

  map.resources :topics, :path_prefix => "admin/sites/:site_id/sections/:section_id",
                         :name_prefix => "admin_",
                         :namespace   => "admin/"

  map.resources :boards, :path_prefix => "admin/sites/:site_id/sections/:section_id",
                         :name_prefix => "admin_",
                         :namespace   => "admin/",
                         :member      => {:update_all => :put}
end