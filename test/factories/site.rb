Factory.define :site do |s|
  s.title 'site title'
  s.name 'site name'
  s.host 'www.example.com'
end

Factory.define :site_with_section, :class => Site do |s|
  s.title 'site title'
  s.name 'site name'
  s.host 'www.example.com'
  s.sections{|s| [s.association(:section)] }
end

Factory.define :site_with_wiki, :class => Site do |s|
  s.title 'site title'
  s.name 'site name'
  s.host 'www.example.com'
  s.sections{|s| [s.association(:wiki)] }
end