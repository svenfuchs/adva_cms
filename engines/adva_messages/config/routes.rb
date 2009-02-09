ActionController::Routing::Routes.draw do |map|
  map.resources :messages, 
                  :collection => {
                    :sent => :get
                  },
                  :member => {
                    :reply => :get
                  }

  map.resources :conversations
end