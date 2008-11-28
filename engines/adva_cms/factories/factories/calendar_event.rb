Factory.sequence :calendar_event do |n|
  "Calendar #{n}"
end

Factory.define :calendar_event do |s|
  s.title { Factory.next :calendar_event }
end
