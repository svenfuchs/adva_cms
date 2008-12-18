Factory.define :newsletter do |n|
  n.title "adva-cms Newsletter"
  n.desc "adva-cms Newsletter desc"
  n.site { |n| n.association(:site) }
end

Factory.define :deleted_newsletter do |i|
  i.title "deleted newsletter title"
  i.desc "deleted newsletter desc"
  i.deleted_at Time.local(2008, 12, 17, 19, 0, 0)
  i.site { |i| i.association(:site) }
end
