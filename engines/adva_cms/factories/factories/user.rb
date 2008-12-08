Factory.sequence :email do |n|
  "john.doe.#{n}@example.com"
end

Factory.sequence :login do |n|
  "johndoe#{n}"
end

Factory.define :user do |u|
  u.first_name "John"
  u.last_name "Doe"
  u.email { Factory.next :email }
  # u.login { Factory.next :login }
  u.password "password123"
  u.verified_at Time.local(2008, 10, 16, 22, 0, 0)
end

Factory.define :unverified_user, :class => User do |u|
  u.first_name 'name'
  u.last_name ''
  u.email 'email@email.org'
  u.password 'password'
  u.verified_at nil
end

Factory.define :other_user do |u|
  u.first_name 'Other'
  u.last_name 'User'
  u.email { Factory.next :email }
  u.password 'password123'
  u.vertified_at Time.local(2008, 12, 8, 17, 0, 0)
end
