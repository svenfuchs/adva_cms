Factory.define :wikipage do |wp|
  wp.title  'wiki home'
  wp.body   'this is a wiki home page'
  wp.author {|wp| wp.association(:user) }
end