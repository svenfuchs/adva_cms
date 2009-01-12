require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'test_helper' ))

class EventsTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_calendar
    factory_scenario :site_with_location
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

  test "admin submits an empty event: should be error" do
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events/new"
    fill_in :calendar_event_title, :with => nil
    fill_in :calendar_event_location_id, :with => nil
    fill_in :location_title, :with => nil
    click_button 'Save'

    assert_template 'admin/events/new'
    assert_select '.field_with_error'
  end

  test "admin submits a new event: should be success" do
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events/new"
    fill_in :calendar_event_title, :with => 'Christmas'
    fill_in :calendar_event_start_date, :with => '2009-12-24'
    fill_in :calendar_event_location_id, :with => @location.id
    fill_in :location_title, :with => nil
    click_button 'Save'

    assert_template 'admin/events/edit'
    assert_select '.field_with_error', false
  end

  test "admin submits a new event with a new location: should be success" do
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events/new"
    fill_in :calendar_event_title, :with => 'Christmas'
    fill_in :calendar_event_start_date, :with => '2009-12-24'
    fill_in :calendar_event_location_id, :with => nil
    fill_in :location_title, :with => 'A new location'
    click_button 'Save'

    assert_template 'admin/events/edit'
    assert_select '.field_with_error', false
  end

  test "admin edits an event: should be success" do
  end
  
  test "admin deletes an event" do
  end
end
