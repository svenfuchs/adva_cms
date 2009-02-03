require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class CalendarRoutesTest < ActionController::TestCase
  tests EventsController

  with_common :calendar_with_events

  paths = %W( /calendars/1/events
              /calendars/1/events/2009
              /calendars/1/events/2009/02
              /calendars/1/events/2009/02/02
              /calendars/1/event/1
              /calendars/1/event/2007 )

  paths.each do |path|
    test "regenerates the original path from the recognized params for #{path}" do
      without_routing_filters do
        params = ActionController::Routing::Routes.recognize_path(path, :method => :get)
        assert_equal path, @controller.url_for(params.merge(:only_path => true))
      end
    end
  end

  describe "routing" do
    calendar_id = Calendar.find_by_permalink('calendar-with-events').id.to_s

    with_options :section_id => calendar_id, :controller => 'events', :action => 'index' do |r|
      r.it_maps :get, "/calendar-with-events"
      r.it_maps :get, "/calendar-with-events/events/2008", :year => "2008"
      r.it_maps :get, "/calendar-with-events/events/2008/11", :year => "2008", :month => "11"
      r.it_maps :get, "/calendar-with-events/events/2008/11/27", :year => "2008", :month => "11", :day => "27"
      r.it_maps :get, "/calendar-with-events/categories/2", :category_id => "2"
    end

    with_options :section_id => calendar_id, :controller => 'events', :action => 'show' do |r|
      r.it_maps :get, "/calendar-with-events/event/1", :id => "1"
      r.it_maps :get, "/calendar-with-events/event/2008", :id => "2008"
      r.it_maps :get, "/calendar-with-events/event/a-jazz-concert", :id => 'a-jazz-concert'
    end
  end
end
