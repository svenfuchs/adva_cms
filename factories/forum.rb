Factory.define :forum do |f|
  f.title "adva-cms Forum"
  f.site_id { |b| b.association(:site_with_forum) }
end