class Calendar < Section
  has_many :events, :foreign_key => 'section_id', :class_name => 'CalendarEvent'
    
  class << self
    def content_type
      'CalendarEvent'
    end
  end
end
