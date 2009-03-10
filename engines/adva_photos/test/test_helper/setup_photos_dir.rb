class ActiveSupport::TestCase
  def setup_photos_dir!
    Photo.root_dir = "#{RAILS_ROOT}/tmp"
  end
  
  def clear_photos_dir!
    FileUtils.rm_r "#{Photo.root_dir}/photos" if File.exists? "#{Photo.root_dir}/photos"
  end
end