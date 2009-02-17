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
      @categories = @section.categories
      @events = @section.events.published
      @event = @events.first
      @site = @section.site
      set_request_host!
    end
  end

  share :valid_event_params do
    before do
      @params = { :calendar_event => {:title => 'A valid event', 
            :start_date => Time.now.to_s, 
            :end_date   => (Time.now + 1.hour).to_s,
            :section_id => @section.id,
            :user_id    => @user.id
            }
      }
    end
  end
  
  share :invalid_event_params do
    before do
      @params = { :calendar_event => {:title => 'A invalid event with an end date before the start date',
            :start_date => Time.now.to_s,
            :end_date   => (Time.now - 1.hour).to_s,
            :section_id => @section.id,
            :user_id    => @user.id
            }
      }
    end
  end
end