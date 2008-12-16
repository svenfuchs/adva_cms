Factory.define_scenario :site_with_an_album do
  factory_scenario :empty_site
  @album ||= @site.sections.build Factory.attributes_for(:album, :type => 'Album')
  @album.save
end