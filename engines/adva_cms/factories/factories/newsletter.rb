Factory.define :newsletter do |n|
  n.title "adva-cms Newsletter"
  n.desc "adva-cms Newsletter desc"
  n.site { |n| n.association(:site) }
end
