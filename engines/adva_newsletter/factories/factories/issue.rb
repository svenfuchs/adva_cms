Factory.define :issue do |i|
  i.title "issue title"
  i.body "issue body"
  i.newsletter { |i| i.association(:newsletter) }
end

Factory.define :deleted_issue do |i|
  i.title "deleted issue title"
  i.body "deleted issue body"
  i.deleted_at Time.local(2008, 12, 17, 17, 0, 0)
  i.newsletter { |i| i.association(:newsletter) }
end
