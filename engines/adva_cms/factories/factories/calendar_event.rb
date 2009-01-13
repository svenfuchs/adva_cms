Factory.sequence :calendar_event do |n|
  "Calendar #{n}"
end

Factory.define :calendar_event do |c|
  c.title { Factory.next :calendar_event }
  c.start_date '2008-11-27'
  c.user_id 1
  c.location_id 1
end
