define Calendar::Event do
  belongs_to :calendar
  instance :event,
           :id => 1,
           :save => true,
           :update_attributes => true,
           :attributes => true,
           :has_attribute? => true,
           :destroy => true
end


