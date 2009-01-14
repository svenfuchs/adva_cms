require File.dirname(__FILE__) + "/../spec_helper"

describe EventsController do
  include SpecControllerHelper
  with_routing_filter

  before :each do
    stub_scenario :calendar_with_events

    controller.instance_variable_set :@site, @site
  end

  describe "routing" do
    with_options :section_id => "1" do |route|
      route.it_maps :get, "/calendars/1/event/1", :show, :id => "1"
      route.it_maps :get, "/calendars/1", :index
      route.it_maps :get, "/calendars/1/categories/2", :index, :category_id => "2"
      route.it_maps :get, "/calendars/1/event/2008", :show, :id => "2008"
      route.it_maps :get, "/calendars/1/event/a-jazz-concert", :show, :id => 'a-jazz-concert'
      route.it_maps :get, "/calendars/1/events/2008", :index, :year => "2008"
      route.it_maps :get, "/calendars/1/events/2008/11", :index, :year => "2008", :month => "11"
      route.it_maps :get, "/calendars/1/events/2008/11/27", :index, :year => "2008", :month => "11", :day => "27"
    end
  end
  describe "routing with icalendar format" do 
    with_options :section_id => '1', :format => 'ics' do |route|
      route.it_maps :get, "/calendars/1/event/1.ics", :show, :id => "1"

      route.it_maps :get, '/calendars/1.ics', :index
      route.it_maps :get, '/calendars/1/categories/2.ics', :index, :category_id => '2'

    end
  end
end