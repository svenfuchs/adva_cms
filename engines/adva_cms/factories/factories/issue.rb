Factory.define :issue do |i|
  i.title "issue title"
  i.body "issue body"
  i.newsletter { |i| i.association(:newsletter) }
end
