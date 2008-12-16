Factory.define :photo do |a|
  a.title         "Test photo"
  a.permalink     "test-photo"
  a.content_type  "image/png"
  a.size          50
  a.filename      "adva_cms_logo"
end

Factory.define :photo_2, :class => Photo do |a|
  a.title         "Second test photo"
  a.permalink     "second-test-photo"
  a.content_type  "image/png"
  a.size          60
  a.filename      "random_image"
end