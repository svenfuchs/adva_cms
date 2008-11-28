define Calendar do
  belongs_to :site
  has_many :categories

  has_many :events, [:find] => :stub_calendar_event

  methods  :id => 1,
           :title => 'calendar title',
           :description => 'calendar description',
           :find => true,
           :save => true,
           :update_attributes => true,
           :destroy => true

  instance :calendar
end

