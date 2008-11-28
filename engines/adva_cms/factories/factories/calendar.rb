Factory.sequence :calendar do |n|
  "Calendar #{n}"
end

Factory.define :calendar do |s|
  s.title { Factory.next :calendar }
#  s.type 'Calendar'
end
