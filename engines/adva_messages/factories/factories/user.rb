Factory.sequence :email do |n|
  "email.#{n}@example.com"
end

Factory.define :don_macaroni, :class => User do |u|
  u.first_name 'Don'
  u.last_name  'Macaroni'
  u.email      { Factory.next :email }
  u.password   'Spaghetti'
  u.verified_at Time.local(2008, 10, 16, 22, 0, 0)
end

Factory.define :johan_mcdoe, :class => User do |u|
  u.first_name  "Johan"
  u.last_name   "McDoe"
  u.email       { Factory.next :email }
  u.password    "password"
  u.verified_at Time.local(2008, 10, 16, 22, 0, 0)
end