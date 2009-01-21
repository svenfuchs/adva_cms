require File.expand_path(File.join(File.dirname(__FILE__), '../', 'test_helper' ))

class EventsTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_calendar
    factory_scenario :calendar_with_event
    Factory :calendar_event, :title => 'Miles Davis Live', :section => @section
    @calendar_path = '/' + @section.permalink
  end

  test "01 GET :index without any events" do
    @section.events.published.update_all(:published_at => nil)
    visit @calendar_path
    assert_template 'events/index'
    assert_select '.empty'
    assert assigns['events'].empty?
  end

  test "02 search for a query and apply filters" do
    %w(tags title body).each do |filter|
      %(upcoming elapsed recently_added).each do |scope|
        visit @calendar_path
        fill_in :filterlist, :with => filter
        fill_in :time_filterlist, :with => scope
        click_button 'Search'
        assert_response :success
        assert assigns['events']
      end
    end
  end
  test "03 GET :index for a date" do
    
  end
  test "04 show event" do
    visit @calendar_path
    assert ! assigns['events'].empty?
    assert_template 'events/index'
    click_link assigns['events'].first.title
    assert_response :success
    assert_template 'events/show'
    assert assigns['event']
  end

  test "05 try event that's not published" do
    calendar_event = @section.events.published.first
    calendar_event.update_attribute(:published_at, nil)
    visit @calendar_path + '/events/' + calendar_event.permalink
    assert_response 404
    assert_nil assigns['event']
  end
end
