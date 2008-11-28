define Calendar::Event do
  belongs_to :calendar
  instance :event,
           :id => 1,
           :save => true,
           :update_attributes => true,
           :destroy => true
end


