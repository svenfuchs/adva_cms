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
         
scenario :cached_page do
  @cached_page = stub_cached_page  
  @cached_pages = stub_cached_pages
end
