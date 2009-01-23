Factory.sequence :site_title do |n|
  "Site Title #{n}"
end
Factory.sequence :site_name do |n|
  "Site Name #{n}"
end
Factory.sequence :host do |n|
  "www#{n}.example.com"
end

Factory.define :site do |s|
  s.name { Factory.next :site_name }
  # s.host { Factory.next :host } # TODO doesn't work for all the adva-cms frontend integration tests
  s.host "www.example.com"
  s.email "site@example.com"
end

Factory.define :other_site, :class => Site do |s|
  s.name  { Factory.next :site_name }
  s.host  { Factory.next :host }
end

Factory.define :site_with_section, :class => Site do |s|
  s.name 'site name'
  # s.host 'www.example.com'
  s.host { Factory.next(:host) }
  s.sections{|s| [s.association(:section)] }
end

Factory.define :site_with_wiki, :class => Site do |s|
  s.name 'site name'
  s.host 'www.example.com'
  s.sections{|s| [s.association(:wiki)] }
end

Factory.define :site_with_blog, :class => Site do |s|
  s.name "adva-cms Test"
  s.host "www.adva-cms.org"
  s.sections { |s| [s.association(:blog)] }
end
