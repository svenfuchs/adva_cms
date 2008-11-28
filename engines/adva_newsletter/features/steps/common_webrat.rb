# Commonly used webrat steps
# http://github.com/brynary/webrat

When /I press '(.*)'/ do |button|
  click_button(button)
end

When /[I click | click] '(.*)'/ do |link|
  click_link(link)
end

When /I fill in '(.*)' for '(.*)'/ do |value, field|
  fill_in(field, :with => value) 
end

When /I check '(.*)'/ do |field|
  check(field) 
end

When /I go to '(.*)'/ do |path|
  visit(path) 
end

Then /I should see '(.*)'/ do |text|
  response.body.should =~ /#{text}/m
end

Then /I should not see '(.*)'/ do |text|
  response.body.should_not =~ /#{text}/m
end
