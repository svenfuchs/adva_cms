class Test::Unit::TestCase
  def ensure_single_site_mode!
    @old_multi_sites_enabled = Site.multi_sites_enabled
    Site.multi_sites_enabled = false
  end

  def rollback_multi_site_mode!
    Site.multi_sites_enabled = @old_multi_sites_enabled
  end
end