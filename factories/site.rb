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

Factory.define :site_with_blog, :class => Site do |s|
  s.name "adva-cms Test"
  s.title "adva-cms Testsite"
  s.host "www.adva-cms.org"
  s.sections { |s| [s.association(:blog)] }
end