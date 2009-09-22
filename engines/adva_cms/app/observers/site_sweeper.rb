class SiteSweeper < ActionController::Caching::Sweeper
  observe Site

  def after_save(site)
    purge_cache_by(site)
  end

  alias after_destroy after_save
end
