require 'pathname'

factories :sections, :articles

steps_for :cached_page do
  Given "page cache is enabled and empty" do
    Given 'no pages are cached'
  end
    
  Given 'no pages are cached' do
    CachedPage.delete_all
    cache_dir = ActionController::Base.page_cache_directory
    FileUtils.rm_r(Dir.glob(cache_dir + "/*")) unless cache_dir.blank? or cache_dir == RAILS_ROOT + "/public"
  end
  
  Then "the page is cached" do
    path = ActionController::Base.send :page_cache_path, request.request_uri
    Pathname.new(path).should exist
  end
  
  Then "the page is not cached" do
    path = ActionController::Base.send :page_cache_path, request.request_uri
    Pathname.new(path).should_not exist
  end
  
end