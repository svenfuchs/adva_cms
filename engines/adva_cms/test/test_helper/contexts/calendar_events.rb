class Test::Unit::TestCase
  share :calendar_without_events do
    before do
      @section = Calendar.find_by_permalink 'calendar-without-events'
      @site = @section.site
      set_request_host!
    end
  end
  share :calendar_with_events do
    before do
      @section = Calendar.find_by_permalink 'calendar-with-events'
      @site = @section.site
      set_request_host!
    end
  end
end