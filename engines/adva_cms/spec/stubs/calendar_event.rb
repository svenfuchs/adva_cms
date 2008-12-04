define CalendarEvent do
  belongs_to :calendar
  instance :event,
           :id => 1,
           :save => true,
           :update_attributes => true,
           :attributes => true,
           :has_attribute? => true,
           :destroy => true,
           :created_at => Time.now,
           :startdate => Time.now,
           :enddate => Time.now
end


