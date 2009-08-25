class ActiveSupport::TestCase
  setup    :setup_assets_dir!
  teardown :clear_assets_dir!

  def setup_assets_dir!
    Asset.root_dir = "#{RAILS_ROOT}/tmp"
  end

  def clear_assets_dir!
    Dir["#{Asset.root_dir}/sites/*/assets"].each { |path| FileUtils.rm_r(path) }
  end
end
