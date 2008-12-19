Factory.define_scenario :site_with_an_album do
  factory_scenario :empty_site
  @album ||= Factory :album, :site => @site, :type => 'Album'
  @paul  ||= Factory :paul_photographer
  @photo ||= Factory :photo, :author => @paul, :section => @album
end

Factory.define_scenario :site_with_an_album_sets_and_tags do
  factory_scenario :site_with_an_album
  @summer_photo ||= Factory :photo, :author => @paul, :section => @album, :title => 'Summer', :published_at => Time.now
  @winter_photo ||= Factory :photo, :author => @paul, :section => @album, :title => 'Winter', :published_at => Time.now
  
  @summer_set   ||= Factory :set, :section => @album
  @summer_photo.sets << @summer_set
  @winter_set   ||= Factory :set, :section => @album, :title => 'Winter'
  @winter_photo.sets << @winter_set
  
  @season_tag   ||= Tag.create!(:name => 'Seasons')
  @summer_photo.tags << @season_tag
  @winter_photo.tags << @season_tag
  @empty_tag    ||= Tag.create!(:name => 'Empty')
end