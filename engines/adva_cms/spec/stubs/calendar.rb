define Calendar do
  belongs_to :site
  has_many :categories, [:roots] => stub_categories

  has_many :events, stub_calendar_events, [:find, :find_by_id, :find_by_permalink, :build, :new, :create] => stub_calendar_event, :class_name => 'CalendarEvent'

  methods  :id => 1,
           :title => 'calendar title',
           :description => 'calendar description',
           :find => true,
           :save => true,
           :update_attributes => true,
           :attributes => true,
           :has_attribute? => true,
           :destroy => true

  instance :calendar
end

