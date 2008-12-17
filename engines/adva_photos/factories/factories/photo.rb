Factory.define :photo do |a|
  a.title         "Test photo"
  a.content_type  "image/png"
  a.size          50
  a.filename      "adva_cms_logo"
  a.position      1
end

Factory.define :photo_2, :class => Photo do |a|
  a.title         "Second test photo"
  a.content_type  "image/png"
  a.size          60
  a.filename      "random_image"
  a.position      2
end