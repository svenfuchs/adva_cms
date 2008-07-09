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

  Given 'a page is cached' #do
  #  path = ActionController::Base.send :page_cache_path, '/'
    # Cache page here 
  #  Pathname.new(path).should exist
  #end
  
  When "the user visits the site's cache index page" do
    raise "this step expects the variable @blog or @site to be set" unless @blog or @site
    object = (@blog || @site)
    site = object.is_a?(Site) ? object : object.site
    get admin_cached_pages_path(site)
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
