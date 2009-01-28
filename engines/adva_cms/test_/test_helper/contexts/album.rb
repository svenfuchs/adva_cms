class Test::Unit::TestCase
  share :a_site_with_album do
    before do
      @album  = Album.find_by_permalink 'an-album'
      @site   = @album.site
      @photo  = @album.photos.first
      set_request_host!
    end
  end
  
  share :a_set do
    before do
      @set = @album.sets.first
    end
  end
end