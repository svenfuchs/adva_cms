Factory.sequence :section do |n|
  "Section #{n}"
end

Factory.define :section do |s|
  s.title { Factory.next :section }
  # s.type 'Section'
end