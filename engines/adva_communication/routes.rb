map.resources :messages, 
                :collection => {
                  :outbox => :get
                }
