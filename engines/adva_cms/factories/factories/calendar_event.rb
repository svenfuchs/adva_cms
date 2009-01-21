Factory.sequence :calendar_event do |n|
  "Calendar Event #{n}"
end

Factory.define :calendar_event do |c|
  c.title { Factory.next :calendar_event }
  c.start_date Time.now
  c.end_date Time.now + 2.hours
  c.published_at Time.now
  c.user_id 1
  c.location_id 1
end
