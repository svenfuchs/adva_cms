class AlbumComponent < Components::Base
  def single(*args)
    options = args.extract_options!.symbolize_keys

    @album = Album.find(:first, :conditions => ["id = ? OR permalink = ?", options[:section], options[:section]])
    @photo = Photo.find(options[:photo_id], :conditions => "published_at IS NOT NULL") if options[:photo_id]
    @photo = @album.photos(:conditions => "published_at IS NOT NULL").first unless @photo
    render
  end
end