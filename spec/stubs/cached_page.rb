define CachedPage do
  belongs_to :site
  belongs_to :section

  instance :cached_page,
           :id => 1,
           :url => 'http://foo.bar/baz', 
           :email => 'foo@bar.baz',
           :save => true,
           :destroy => true,
           :site => stub_site
end