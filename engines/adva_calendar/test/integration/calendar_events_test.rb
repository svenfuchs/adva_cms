require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class CalendarEventsTest < ActionController::IntegrationTest

    def setup
      super
      Time.stubs(:now).returns Time.utc(2009,2,3, 15,00,00)
      Date.stubs(:today).returns Date.civil(2009,2,3)
      @site = use_site! 'site with calendar'
      @calendar = @site.sections.find_by_permalink('calendar-with-events')
      @event = @calendar.events.published.first
      @calendar_path = '/' + @calendar.permalink
    end

    test "01 GET :index without any events" do
      visit '/' + @site.sections.find_by_permalink('calendar-without-events').permalink
      assert_template 'events/index'
      assert_select '.empty'
      assert assigns['events'].empty?
    end

    test "02 search for a query and apply filters" do
      visit @calendar_path

      if default_theme?
        %w(tags title body).each do |filter|
          %(upcoming elapsed recently_added).each do |scope|
            visit @calendar_path
            fill_in :filter_list, :with => filter
            fill_in :time_filter_list, :with => scope
            click_button 'calendar_events_search'
            assert_response :success
            assert assigns['events']
          end
        end
      end
    end

    test "03 GET :index for a date" do
      visit @calendar_path + '/' + Date.today.strftime('%Y/%m/%d')
      assert_response :success
      assert assigns['events']
    end

    test "04 GET :index for a category" do
      visit @calendar_path + '/categories/' + @calendar.categories.first.permalink
      assert_response :success
      assert assigns['events']
    end

    test "05 show event" do
      visit @calendar_path
      assert assigns('events')
      assert_template 'events/index'
      click_link @event.title
      assert_response :success
      assert_template 'events/show'
      assert assigns['event']
    end

    test "06 try event that's not published" do
      calendar_event = @calendar.events.published.first
#      calendar_event.update_attribute(:published_at, nil)
      visit @calendar_path + '/events/' + calendar_event.permalink
      assert_response 404
      assert_nil assigns['event']
    end
  end
end