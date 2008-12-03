Given /site has no users/ do
  Site.find(1).users.destroy_all
end

Given /site has users/ do
  site = Site.find(1)
  site.users.destroy_all
  site.users.create(valid_user)
end

def valid_user
  {
    :first_name => 'Site user',
    :email => 'site_user@example.org',
    :password => 'password'
  }
end
