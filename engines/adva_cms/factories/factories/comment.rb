Factory.define :approved_comment, :class => Comment do |c|
  c.body "Yes, I think that's a very good idea."
  c.approved true
  c.author { |c| c.association(:user) }
end

Factory.define :unapproved_comment, :class => Comment do |c|
  c.body "I don't think that that's a very good idea ..."
  c.approved false
  c.author { |c| c.association(:user) }
end