Factory.define :category do |c|
  c.title "General Information"
end

Factory.define :unrelated_category, :class => Category do |c|
  c.title "Private Rantings"
end