class Test::Unit::TestCase
  def setup_assets_dir!
    # Asset.root_dir = RAILS_ROOT + '/tmp'
    Asset.root_dir = '/tmp'
  end
  
  def clear_assets_dir!
    FileUtils.rm_r Asset.base_dir if File.exists?(Asset.base_dir)
  end
end
