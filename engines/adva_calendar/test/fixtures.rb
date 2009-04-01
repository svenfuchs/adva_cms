user = User.find_by_first_name('a user')
admin = User.find_by_first_name('an admin')

site_with_calendars =
Site.create!     :name  => 'site with calendar',
                 :title => 'site with calendar title',
                 :host  => 'site-with-calendar.com'

admin.roles << Rbac::Role.build(:admin, :context => site_with_calendars)
site_with_calendars.users << admin
site_with_calendars.users << user

calendar_without_events =
Calendar.create! :site        => site_with_calendars,
                 :title       => 'a calendar without events',
                 :permalink   => 'calendar-without-events'

calendar_with_events =
Calendar.create! :site        => site_with_calendars,
                 :title       => 'a calendar with events',
                 :permalink   => 'calendar-with-events'


time = Time.utc(2009, 2, 3, 15, 0, 0)

# 2009-2-8
an_upcoming_event =
CalendarEvent.create! :section => calendar_with_events,
                      :title => 'an upcoming event',
                      :body => 'We are so much looking forward for this event',
                      :user => user,
                      :start_date => time + 5.days,
                      :end_date => time + 5.days + 2.hours,
                      :published_at => time

# 2009-1-29 to 2009-2-3
an_ongoing_event =
CalendarEvent.create! :section => calendar_with_events,
                      :title => 'an ongoing event',
                      :body => 'This event started earlier and will end soon',
                      :user => user,
                      :start_date => time - 5.days,
                      :end_date => time + 2.hours,
                      :published_at => time - 1.week

# 2009-1-31
a_past_event =
CalendarEvent.create! :section => calendar_with_events,
                      :title => 'a past event',
                      :body => 'The event took place three days ago',
                      :user => user,
                      :start_date => time - 3.days,
                      :end_date => time - 3.days + 2.hours,
                      :published_at => time - 1.week

# 2008-2-3
a_event_last_year =
CalendarEvent.create! :section => calendar_with_events,
                      :title => 'a event last year',
                      :body => 'We had a lot of fun last year',
                      :user => user,
                      :start_date => time - 1.year,
                      :end_date => time - 1.year + 2.hours,
                      :published_at => nil

category_jazz =
Category.create! :section => calendar_with_events,
                 :title => 'Jazz'

category_rock =
Category.create! :section => calendar_with_events,
                 :title => 'Rock'

category_punk =
Category.create! :section => calendar_with_events,
                 :title => 'Punk'

an_upcoming_event.categories = [category_jazz, category_rock]
an_ongoing_event.categories  = [category_jazz, category_punk]
a_past_event.categories      = [category_punk]
a_event_last_year.categories = [category_rock]
