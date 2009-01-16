require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'test_helper' ))

class EventsTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_calendar
    factory_scenario :site_with_location
    factory_scenario :calendar_with_event
    login_as :admin
  end

  test "01 GET :index without any events" do
    CalendarEvent.delete_all
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events"
    assert_template 'admin/events/index'
    assert_select '.empty'
    assert_select '.empty>a', 'Create a new event'
    assert assigns['events'].empty?
  end

  test "02 GET :index using filter, without any events" do
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events?filter=tags&query=null"
    assert_template 'admin/events/index'
    assert_select '.empty'
    assert_select '.empty', 'No events matching your filter.'
  end

  test "03 admin submits an empty event: should be error" do
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events/new"
    fill_in :calendar_event_title, :with => nil
    fill_in :calendar_event_location_id, :with => nil
    fill_in :location_title, :with => nil
    click_button 'Save'

    assert_template 'admin/events/new'
    assert_select '.field_with_error'
    assert assigns['event'].new_record?
  end

  test "04 admin submits a new event: should be success" do
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events/new"
    fill_in :calendar_event_title, :with => 'Christmas'
    fill_in :calendar_event_start_date, :with => '2009-12-24'
    fill_in :calendar_event_location_id, :with => @location.id
    fill_in :location_title, :with => nil
    click_button 'Save'

    assert_template 'admin/events/edit'
    assert_select '.field_with_error', false
    assert ! assigns['event'].new_record?
    assert_equal 'Christmas', assigns['event'].title
  end

  test "05 admin submits a new event with a new location: should be success" do
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events/new"
    fill_in :calendar_event_title, :with => 'Christmas'
    fill_in :calendar_event_start_date, :with => '2009-12-24'
    fill_in :calendar_event_location_id, :with => nil
    fill_in :location_title, :with => 'A new location'
    click_button 'Save'

    assert_template 'admin/events/edit'
    assert_select '.field_with_error', false
    assert ! assigns['event'].new_record?
  end

  test "06 admin edits an event: should be success" do
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events/#{@event.id}/edit"
    assert_template 'admin/events/edit'
    fill_in :calendar_event_title, :with => 'A new title'
    fill_in :calendar_event_body, :with => 'An updated description'
    click_button 'Save'
    assert_template 'admin/events/edit'
    assert_select '.field_with_error', false
    @event.reload
    assert_equal 'An updated description', @event.body
  end

  test "07 admin edits an event with a new location: should be success" do
    visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events/#{@event.id}/edit"
    old_location_id = @event.location_id
    assert_template 'admin/events/edit'
    fill_in :calendar_event_location_id, :with => nil
    fill_in :location_title, :with => 'A new completly location'
    click_button 'Save'
    assert_template 'admin/events/edit'
    assert_select '.field_with_error', false
    @event.reload
    assert_not_equal old_location_id, @event.location_id
  end

  # test "08 admin deletes an event" do
  #   visit "/admin/sites/#{@site.id}/sections/#{@section.id}/events"
  #   assert_template 'admin/events/index'
  #   click_link @event.title
  #   assert_template 'admin/events/edit'
  #   click_link 'Delete'
  # 
  #   assert_template 'admin/events/index'
  #   assert_select "event_%i" % @event.id, false
  # end
end
