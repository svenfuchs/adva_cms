Given /I am logged in as '(.*)'/ do |user|
  if Site.find(:first).nil?
    visit '/'
    fill_in :site_name, :with => 'example'
    click_button :create_site_and_account
  end

  visit '/admin/sites/1'
  fill_in(:user_email, :with => "#{user}@example.org")
  fill_in(:user_password, :with => "#{user}")
  click_button 'Login'
end
