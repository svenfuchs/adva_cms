class Test::Unit::TestCase
  class << self
    def setup_assets_dir!
      Asset.base_dir = RAILS_ROOT + '/tmp/assets'
    end
    
    def clear_assets_dir!
      FileUtils.rm_r Asset.base_dir if File.exists?(Asset.base_dir)
    end
  end
end
