Factory.define :newsletter do |n|
  n.title "adva-cms Newsletter"
  n.desc "adva-cms Newsletter desc"
  n.site { |n| n.association(:site) }
end

Factory.define :deleted_newsletter do |n|
  n.title "deleted newsletter title"
  n.desc "deleted newsletter desc"
  n.deleted_at Time.local(2008, 12, 17, 19, 0, 0)
  n.site { |n| n.association(:site) }
end
