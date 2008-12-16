Factory.sequence :email do |n|
  "email.#{n}@example.com"
end

Factory.define :paul_photographer, :class => User do |u|
  u.first_name 'Paul'
  u.last_name  'Photographer'
  u.email      { Factory.next :email }
  u.password   'Photosarenice'
  u.verified_at Time.local(2008, 10, 16, 22, 0, 0)
end