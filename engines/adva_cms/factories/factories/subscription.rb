Factory.define :subscription do |s|
  s.user { |s| s.association(:other_user) }
  # DOTO figure out how do poly with with factory
  # s.subscribable_id 1 
  # s.subscribable_type 'Newsletter'
end
