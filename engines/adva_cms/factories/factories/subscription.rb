Factory.define :subscription do |s|
  s.user { |s| s.association(:other_user) }
  s.subscribable_id { |s| s.association(:newsletter).id }
  s.subscribable_type 'Newsletter'
end
