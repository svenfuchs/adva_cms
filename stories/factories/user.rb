factory :user, 
        :name => 'name', 
        :email => 'email@email.org', 
        :login => 'login',
        :password => 'password', 
        :password_confirmation => 'password'
        
factory :author, valid_user_attributes, :class => :user
