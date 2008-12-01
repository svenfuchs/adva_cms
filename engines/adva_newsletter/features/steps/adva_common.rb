Given /I am logged in as "(.*)"/ do |user|
  if Site.find(:first).nil?
    visit '/'
    fill_in :site_name, :with => 'example'
    click_button :create_site_and_account
  else
    visit '/admin/sites/1'
    fill_in(:user_email, :with => "#{user}@example.org")
    fill_in(:user_password, :with => "#{user}")
    click_button 'Login'
  end
end

When /[I submit | submit] new "(.*)"/ do |model|
  case model
  when 'draft newsletter'
    fill_in :title, :with => 'draft newsletter title'
    fill_in :body, :with => 'draft newsletter body'
  when 'empty newsletter'
  else
    raise missing_from_step(model)
  end

  click_button 'Save'
end

Then /[I should | should ] see new "(.*)"/ do |model|
  case model
  when 'draft newsletter'
    response.body.should include_text('draft newsletter title')
    response.body.should include_text('draft newsletter body')
  else
    raise missing_from_step(model)
  end
end

Then /should have 0 issues/ do
  #TODO find better way and more unique step description
  Newsletter.last.issues.should == []
end

def missing_from_step(model)
  "#{model} is missing from step, please add it"
end
