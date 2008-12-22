class Calendar < Section
  has_many :events, :foreign_key => 'section_id', :class_name => 'CalendarEvent'
    
  class << self
    def content_type
      'CalendarEvent'
    end
  end
  def days_in_month_with_events(date)
    events.find(:all, 
        :select => 'startdate', :order => 'startdate ASC',
        :conditions => ['startdate > ? and startdate < ?', date.beginning_of_month, date.end_of_month]).collect{|e| e.startdate.to_date}
  end
end
