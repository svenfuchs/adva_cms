class AlbumCell < Cell::Base

  tracks_cache_references :recent_articles, :track => ['@album', '@photo']
  
  def single
    options = @opts.symbolize_keys

    @album = Album.find(:first, :conditions => ["id = ? OR permalink = ?", options[:section], options[:section]])
    @photo = Photo.find(options[:photo_id], :conditions => "published_at IS NOT NULL") if options[:photo_id]
    @photo ||= @album.photos(:conditions => "published_at IS NOT NULL").first if @album
    
    nil
  end
end