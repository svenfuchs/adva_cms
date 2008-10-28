Factory.define :tag do |t|
  t.name "rails"
end

Factory.define :unrelated_tag, :class => Tag do |t|
  t.name "java"
end