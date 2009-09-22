class Test::Unit::TestCase
  def setup_caching!
    ActionController::Base.perform_caching = true
  end
  
  def clear_tmp_dir!
    tmp_dir = RAILS_ROOT + '/tmp/sites'
    FileUtils.rm_r(tmp_dir) if File.exists?(tmp_dir)
  end
end
