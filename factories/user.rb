Factory.define :user do |u|
  u.first_name "John"
  u.last_name "Doe"
  u.email "john.doe@example.com"
  u.login "johndoe"
  u.password "jane"
  u.verified_at Time.local(2008, 10, 16, 22, 0, 0)
end

Factory.define :unverified_user, :class => User do |u|
  u.first_name 'name'
  u.last_name ''
  u.email 'email@email.org'
  u.login 'login'
  u.password 'password'
  u.verified_at nil
end