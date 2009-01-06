Factory.define :membership do |m|
  m.user {|m| m.association(:user) }
  m.site {|m| m.association(:site) }
end

Factory.define :other_membership, :class => Membership do |m|
  m.user {|m| m.association(:other_user) }
  m.site {|m| m.association(:site) }
end
