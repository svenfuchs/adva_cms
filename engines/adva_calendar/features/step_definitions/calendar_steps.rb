Given /^I am a logged user$/ do
  visit login_path
  selenium.wait_for_page_to_load
  fill_in "Email", :with => @user.email
  fill_in "Password", :with => 'a password'
  click_button "Login"
end

When /^I am on the new events page/ do
  visit new_admin_calendar_event_path(@site, @section)
  selenium.wait_for_page_to_load
end

And /^I create a meeting as draft event$/ do
  fill_in "Title", :with => "Meeting"
  fill_in "Organizer", :with => "Luca"
  fill_in "Location", :with => "Meeting room"
  fill_in "Starting at", :with => "Thu, 02 Apr 2009 19:00:22 +0200"
  check "All day"
  check "Yes, save this event as a draft"
  click_button "Save"
end

Then /^I should see the meeting event in the events page$/ do
  visit admin_calendar_events_path(@site, @section)
  response.should contain("Meeting")
end