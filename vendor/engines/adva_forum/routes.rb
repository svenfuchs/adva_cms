map.forum 'forums/:section_id',
           :controller   => 'forum',                            
           :action       => "show",
           :requirements => { :method => :get }

map.resources :topics, :path_prefix => 'forums/:section_id', 
                       :member => { :previous => :get, :next => :get } do |topic|
  topic.resources :posts
end
