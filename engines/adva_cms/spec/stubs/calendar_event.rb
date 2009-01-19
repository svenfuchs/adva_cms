define CalendarEvent do
  belongs_to :section, stub_calendar
  belongs_to :location, stub_location
  
  methods :id => 1,
          :title => 'calendar event',
          :permalink => 'calendar-event',
          :host => 'Mr. H. Ost',
          :body => 'Something about this *event*',
          :body_html => 'Something about this <strong>event</strong>',
          :filter => 'textile',
          :location_id => 1,
          :save => true,
          :attributes= => true,
          :all_day= => true,
          :all_day => false,
          :update_attributes => true,
          :attributes => true,
          :has_attribute? => true,
          :destroy => true,
          :created_at => Time.now,
          :start_date => Time.now,
          :end_date => Time.now + 2.hours,
          :published_at => Time.now,
          :draft? => false,
          :track_method_calls => nil,
          :require_end_date => true

  instance :calendar_event
end


