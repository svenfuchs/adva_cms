user1 = User.create!  :first_name => 'user1',
                      :email => 'user1@example.com',
                      :password => 'a password',
                      :verified_at => Time.now
user2 = User.create!  :first_name => 'user2',
                      :email => 'user2@example.com',
                      :password => 'a password',
                      :verified_at => Time.now
user3 = User.create!  :first_name => 'user3',
                      :email => 'user3@example.com',
                      :password => 'a password',
                      :verified_at => Time.now
user4 = User.create!  :first_name => 'user4',
                      :email => 'user4@example.com',
                      :password => 'a password',
                      :verified_at => Time.now

account = Account.create! :name => 'an account', :users => [ user1, user2, user3 ]
