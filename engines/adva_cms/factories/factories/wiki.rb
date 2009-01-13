Factory.define :wiki do |w|
  w.site { |w| w.association(:site) }
  w.title 'Wiki'
end
