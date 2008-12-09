class Location < ActiveRecord::Base
  has_many :events, :class_name => 'CalendarEvent'
end
