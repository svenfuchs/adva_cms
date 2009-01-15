class PhotoSweeper < CacheReferences::Sweeper
  observe Photo
  
  def after_create(photo)
    expire_cached_pages_by_section(photo.section)
  end

  def before_save(photo)
    expire_cached_pages_by_reference(photo)
  end

  alias after_destroy before_save
end