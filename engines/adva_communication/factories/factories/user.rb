Factory.define :don_macaroni, :class => User do |u|
  u.first_name 'Don'
  u.last_name  'Macaroni'
  u.email      'don.macaroni@email.org'
  u.password   'Spaghetti'
  u.verified_at Time.local(2008, 10, 16, 22, 0, 0)
end

Factory.define :johan_mcdoe, :class => User do |u|
  u.first_name  "Johan"
  u.last_name   "McDoe"
  u.email       "johan.mcdoe@email.org"
  u.password    "password"
  u.verified_at Time.local(2008, 10, 16, 22, 0, 0)
end