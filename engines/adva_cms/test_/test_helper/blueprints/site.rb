Sham.site_name {|ix| "Site #{ix}" }
Sham.site_host {|ix| "www#{ix > 1 ? ix : ''}.example.com" }

Site.blueprint do
  name  { Sham.site_name }
  host  { 'www.example.com' }
  title { 'site title' }
end

CachedPage.blueprint do
  url   { '/path/to/permalink' }
end