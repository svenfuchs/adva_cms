Factory.define_scenario :site_with_an_album do
  factory_scenario :empty_site
  @album ||= @site.sections.build Factory.attributes_for(:album, :type => 'Album')
  @album.save!
  @paul   = Factory :paul_photographer
  @photo  ||= @album.photos.build Factory.attributes_for(:photo, :author => @paul)
  @photo.save!
end