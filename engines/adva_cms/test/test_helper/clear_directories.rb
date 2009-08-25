class Test::Unit::TestCase
  def setup_page_caching!
    ActionController::Base.page_cache_directory = RAILS_ROOT + '/tmp/cache'
    ActionController::Base.perform_caching = true
  end
  
  def clear_cache_dir!
    cache_dir = ActionController::Base.page_cache_directory
    FileUtils.rm_r(cache_dir) if File.exists?(cache_dir)
  end
  
  def clear_tmp_dir!
    tmp_dir = RAILS_ROOT + '/tmp/sites'
    FileUtils.rm_r(tmp_dir) if File.exists?(tmp_dir)
  end
end
