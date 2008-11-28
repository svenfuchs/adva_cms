map.resources :messages, 
                :collection => {
                  :sent => :get
                },
                :member => {
                  :reply => :get
                }
