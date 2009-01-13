Factory.sequence :location do |n|
  "Location #{n}"
end

Factory.define :location do |c|
  c.title { Factory.next :location }
end
