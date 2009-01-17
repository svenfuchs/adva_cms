class Test::Unit::TestCase
  def setup_themes_dir!
    Theme.root_dir = "#{RAILS_ROOT}/tmp"
  end
  
  def clear_themes_dir!
    FileUtils.rm_r "#{Theme.root_dir}/themes" if File.exists? "#{Theme.root_dir}/themes"
  end
end