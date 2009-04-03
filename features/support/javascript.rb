# RSpec
require 'spec/expectations'
 
# Webrat
Webrat.configure do |config|
  config.mode = :selenium
end

Before do
  # TODO at this point adva_cms fixtures are loaded into the database,
  # but not as instance variables. Find a way to make them available
  # without instiantiate them there
  @user = User.find_by_email 'a-superuser@example.com'
  @site = Site.find_by_host 'site-with-calendar.com'
  @section = Calendar.find_by_permalink 'calendar-without-events'
end
