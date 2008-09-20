scenario :empty_site do
  @site = stub_site
  @sites = stub_sites

  Site.stub!(:find).and_return @site
  Site.stub!(:find_by_host).and_return @site
  Site.stub!(:paginate).and_return @sites

  Section.stub!(:types).and_return ['Section', 'Blog', 'Forum', 'Wiki']
end