class SectionSweeper < ActionController::Caching::Sweeper
  observe Section

  def after_create(section)
    purge_cache_by(section.site)
  end

  def after_save(section)
    purge_cache_by(section)
  end

  alias after_destroy after_create
end
