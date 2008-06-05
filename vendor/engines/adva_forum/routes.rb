map.forum 'forums/:section_id',
           :controller   => 'forums',                            
           :action       => "show",
           :requirements => { :method => :get }

map.resources :topics, 
              :path_prefix => 'forums/:section_id', 
              :member => { :previous => :get, :next => :get } do |topic|
  topic.resources :posts
end

# resources :forums, :has_many => :posts do |forum|
#   forum.resources :topics do |topic|
#     topic.resources :posts
#     topic.resource :monitorship
#   end
#   forum.resources :posts
# end
