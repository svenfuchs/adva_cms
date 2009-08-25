class ActiveSupport::TestCase
  setup    :setup_photos_dir!
  teardown :clear_photos_dir!

  def setup_photos_dir!
    Photo.root_dir = "#{RAILS_ROOT}/tmp"
  end
  
  def clear_photos_dir!
    Dir["#{Photo.root_dir}/sites/*/photos"].each { |path| FileUtils.rm_r(path) }
  end
end