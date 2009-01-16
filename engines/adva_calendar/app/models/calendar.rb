class Calendar < Section
  has_many :events, :foreign_key => 'section_id', :class_name => 'CalendarEvent'
    
  class << self
    def content_type
      'CalendarEvent'
    end
  end
  def days_in_month_with_events(date)
    @days_in_month_with_events ||= {}
    @days_in_month_with_events[date] ||= events.find(:all, 
        :select => 'start_date, end_date', :order => 'start_date ASC',
        :conditions => ['start_date > ? and start_date < ?', date.beginning_of_month, date.end_of_month]).collect{ |e| 
            e.end_date.blank? ? 
              e.start_date.to_date : 
              Range.new((e.start_date.to_date < date.beginning_of_month) ? 
                  date.beginning_of_month : e.start_date.to_date,
                (e.end_date.to_date > date.end_of_month) ?
                  date.end_of_month : e.end_date.to_date).to_a}.flatten
  end
end
