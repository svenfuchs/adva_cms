Factory.define :unverified_user, :class => User do |u|
  u.name 'name'
  u.email 'email@email.org'
  u.login 'login'
  u.password 'password'
  u.password_confirmation 'password'
  u.verified_at nil
end