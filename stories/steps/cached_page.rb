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

  Given 'a page is cached' do
    @path = ActionController::Base.send :page_cache_path, '/'
    get '/' 
    @cached_page = CachedPage.find(:first)
    Pathname.new(@path).should exist
  end
  
  Given 'the other page is cached' do
    raise "this step expects the variable @section to be set" unless @section
    @other_path = ActionController::Base.send :page_cache_path, "/#{@section.permalink}"
    get "/#{@section.permalink}" 
    @other_cached_page = CachedPage.find(:first)
    Pathname.new(@other_path).should exist
  end

  When "the user visits the site's cache index page" do
    raise "this step expects the variable @blog or @site to be set" unless @blog or @site
    object = (@blog || @site)
    site = object.is_a?(Site) ? object : object.site
    get admin_cached_pages_path(site)
  end

  When "the user clicks on '$link' within cached page" do |link|
    raise "this step expects the variable @cached_page to be set" unless @cached_page
    selector_id = "#cached_page_#{@cached_page.id}"
    delete admin_cached_page_path(@cached_page.site, @cached_page)
    #clicks_link_within selector_id, link
    #response.should have_tag("tr#{selector_id}.deleted")
  end

  Then "the page is cached" do
    path = ActionController::Base.send :page_cache_path, request.request_uri
    Pathname.new(path).should exist
  end
  
  Then "the page is not cached" do
    path = ActionController::Base.send :page_cache_path, request.request_uri
    Pathname.new(path).should_not exist
  end

  Then "the page has a list of cached pages" do
    raise "this step expects the variable @cached_page to be set" unless @cached_page
    response.should have_tag('table#cached_pages')
    response.should have_tag("tr#cached_page_#{@cached_page.id}")
  end

  Then "the cached page's record and file are deleted" do
    raise "this step expects the variable @cached_page and @path to be set" unless @cached_page and @path
    CachedPage.exists?(@cached_page.id).should be_false
    Pathname.new(@path).should_not exist
  end

  Then "the other cached page's record and file are deleted" do
    raise "this step expects the variable @cached_page and @path to be set" unless @other_cached_page and @other_path
    CachedPage.exists?(@other_cached_page.id).should be_false
    Pathname.new(@other_path).should_not exist
  end
end
