Sham.user_name  {|ix| "User #{ix}" }
Sham.user_email {|ix| "email-#{ix > 1 ? ix : ''}@example.com" }

User.blueprint do
  name     { Sham.user_name }
  email    { Sham.user_email }
  password { 'password' }
end