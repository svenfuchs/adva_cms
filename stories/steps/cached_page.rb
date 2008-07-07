factories :sections, :articles

steps_for :cached_page do
  Given "page cache is enabled and no pages are cached" do
    ActionController::Base.page_cache_directory = RAILS_ROOT + '/tmp/cache'
    ActionController::Base.perform_caching = true    
    Given 'no pages are cached'
  end
    
  Given 'no pages are cached' do
    CachedPage.delete_all
    cache_dir = ActionController::Base.page_cache_directory
    unless cache_dir == RAILS_ROOT + "/public"
      FileUtils.rm_r(Dir.glob(cache_dir + "/*")) rescue Errno::ENOENT
    end
  end
  
  Then "the page has been cached" do
    path = ActionController::Base.page_cache_directory + request.request_uri + '.html'
    File.exists?(path).should be_true
  end
  
  Then "the page has not been cached" do
    path = ActionController::Base.page_cache_directory + request.request_uri + '.html'
    File.exists?(path).should be_false
  end
end