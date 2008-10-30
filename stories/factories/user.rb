User.delete_all

factory :user,
        :name => 'name',
        :email => 'email@email.org',
        :login => 'login',
        :password => 'password'

factory :author, valid_user_attributes, :class => :user

factory :verified_user, valid_user_attributes.update(:verified_at => '2008-01-01 12:00:00'), :class => :user