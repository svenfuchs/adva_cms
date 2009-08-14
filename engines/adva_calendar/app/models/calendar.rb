class Calendar < Section
  has_many :events, :foreign_key => 'section_id', :class_name => 'CalendarEvent'
    
  class << self
    def content_type
      'CalendarEvent'
    end
  end

  def days_in_month_with_events(month)
    month = month.beginning_of_month
    end_of_month = month.end_of_month.end_of_day
    @days_in_month_with_events ||= {}
    @days_in_month_with_events[month] ||= events.find(:all, 
        :select => 'start_date, end_date', :order => 'start_date ASC',
        :conditions => ['published_at IS NOT NULL 
            AND ((start_date BETWEEN ? AND ?) 
            OR (start_date <= ? AND end_date >= ?))', 
            month, end_of_month, month, month]
        ).collect{ |e| 
            e.end_date.present? ?
              Range.new(
                (e.start_date < month) ? month : e.start_date.to_date,
                (e.end_date > month.end_of_month.end_of_day) ? month.end_of_month : e.end_date.to_date).to_a :
              e.start_date.to_date
          }.flatten.uniq.sort
      # to explain the chaos above: if there's a end_date we create a range from
      # the start_date (or beginning of month) to end_date (or end of month)
      # convert this range to an array and flatten it.
  end
end
