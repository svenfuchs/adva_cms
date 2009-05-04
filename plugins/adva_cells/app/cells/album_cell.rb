class AlbumCell < BaseCell
  tracks_cache_references :recent_articles, :track => ['@album', '@photo']

  has_state :single

  def single
    # TODO make these before filters
    symbolize_options!
    set_site
    set_section

    @album = Album.find(:first, :conditions => ["id = ? OR permalink = ?", @opts[:section], @opts[:section]])
    @photo = Photo.find(@opts[:photo_id], :conditions => "published_at IS NOT NULL") if @opts[:photo_id]
    @photo ||= @album.photos(:conditions => "published_at IS NOT NULL").first if @album

    nil
  end
end