Factory.sequence :calendar do |n|
  "Calendar #{n}"
end

Factory.define :calendar do |c|
  c.title { Factory.next :calendar }
  c.site { |c| c.association(:site) }
end
