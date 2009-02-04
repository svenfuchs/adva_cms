user = User.find_by_first_name('a user')
admin = User.find_by_first_name('an admin')

site_with_calendars =
Site.create!     :name  => 'site with calendar',
                 :title => 'site with calendar title',
                 :host  => 'site-with-calendar.com'

calendar_without_events =
Calendar.create! :site        => site_with_calendars,
                 :title       => 'a calendar without events',
                 :permalink   => 'calendar-without-events'

calendar_with_events =
Calendar.create! :site        => site_with_calendars,
                 :title       => 'a calendar with events',
                 :permalink   => 'calendar-with-events'


an_upcoming_event =
CalendarEvent.create! :section => calendar_with_events,
                      :title   => 'an upcoming event',
                      :user => user,
                      :start_date => Time.now + 5.days,
                      :end_date => Time.now + 5.days + 2.hours,
                      :published_at => Time.now

an_ongoing_event =
CalendarEvent.create! :section => calendar_with_events,
                      :title   => 'an ongoing event',
                      :user => user,
                      :start_date => Time.now - 5.days,
                      :end_date => Time.now + 2.hours,
                      :published_at => Time.now - 1.week

a_past_event =
CalendarEvent.create! :section => calendar_with_events,
                      :title   => 'a past event',
                      :user => user,
                      :start_date => Time.now - 3.days,
                      :end_date => Time.now - 3.days + 2.hours,
                      :published_at => Time.now - 1.week
category_jazz =
Category.create! :section => calendar_with_events,
                 :title => 'Jazz'
