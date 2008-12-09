Factory.sequence :calendar_event do |n|
  "Calendar #{n}"
end

Factory.define :calendar_event do |c|
  c.title { Factory.next :calendar_event }
end
