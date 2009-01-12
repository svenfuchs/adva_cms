require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'test_helper' ))

class EventsTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_calendar
    login_as :admin
  end

  test "GET :index without any events" do
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events"
    assert_template 'admin/events/index'
    assert_select '.empty'
    assert_select '.empty>a', 'Create a new event'
  end

  test "GET :index using filter, without any events" do
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events?filter=tags&query=null"
    assert_template 'admin/events/index'
    assert_select '.empty'
    assert_select '.empty', 'No events matching your filter.'
  end

  test "admin submits a empty event: should see warnings when doing it"  do
  end

  test "admin submits a new event: should be sucsses" do
  end

  test "admin submits a new event with a new location: should be sucsses" do
  end

  test "admin edits an event: should be success" do
  end
  
  test "admin deletes an event" do
  end
end
