require File.dirname(__FILE__) + "/../spec_helper"

describe EventsController do
  include SpecControllerHelper
  with_routing_filter

  before :each do
    stub_scenario :calendar_with_events

    controller.instance_variable_set :@site, @site
    Thread.current[:site] = @site
  end

  describe "routing" do
    with_options :section_id => "1" do |route|
      route.it_maps :get, "/event/1/1", :show, :id => "1"
      route.it_maps :get, "/event/1/2008", :show, :id => "2008"
      route.it_maps :get, "/events/1/2008", :index, :year => "2008"
      route.it_maps :get, "/events/1/2008/11", :index, :year => "2008", :month => "11"
      route.it_maps :get, "/events/1/2008/11/27", :index, :year => "2008", :month => "11", :day => "27"
    end
    
    with_options :section_id => '1', :format => 'ics' do |r|
      r.maps_to_index '/events/1.ics'
    end
  end
end