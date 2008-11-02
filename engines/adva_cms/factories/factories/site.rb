Factory.sequence :site_title do |n|
  "Site Title #{n}"
end
Factory.sequence :site_name do |n|
  "Site Name #{n}"
end
Factory.sequence :host do |n|
  # Need default domain to work with webrat
  "www#{n}.example.com"
end

Factory.define :site do |s|
  s.title 'Site Title'
  s.name  'Site Name'
  s.host  'www.example.com'
end

Factory.define :other_site, :class => Site do |s|
  s.title { Factory.next :site_title }
  s.name  { Factory.next :site_name }
  s.host  { Factory.next :host }
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
