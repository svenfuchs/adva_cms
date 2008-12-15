define Location do
  belongs_to :site
  has_many :calendar_events
  
  methods :id => 1,
          :title => 'some location',
          :country => 'Austria',
          :postcode => '1070',
          :town => 'Vienna',
          :address => 'Museumsplatz 1',
          :save => true
  instance :location
end


