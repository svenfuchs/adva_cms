define Location do
  belongs_to :site
  
  methods :id => 1,
          :title => 'some location',
          :country => 'Austria',
          :postcode => '1070',
          :town => 'Vienna',
          :address => 'Museumsplatz 1'
end


