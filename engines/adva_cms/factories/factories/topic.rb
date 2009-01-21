Factory.sequence :topic do |n|
  "Test topic #{n}"
end

Factory.define :topic do |t|
  t.title { Factory.next :topic }
  t.body  'This is a test topic'
end