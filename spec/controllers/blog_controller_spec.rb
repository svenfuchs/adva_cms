require File.dirname(__FILE__) + "/../spec_helper"

describe BlogController do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :section, :blog, :article, :category, :tag

    @blog.articles.stub!(:paginate_published_in_time_delta).and_return @articles
    @category.contents.stub!(:paginate_published_in_time_delta).and_return @articles
    @site.sections.stub!(:find).and_return @blog
  end
  
  blog_paths     = %w( /de/blog
                       /de/blog/2000
                       /de/blog/2000/1 )                          
  category_paths = %w( /de/blog/categories/foo  
                       /de/blog/categories/foo/2000
                       /de/blog/categories/foo/2000/1 )                          
  tags_paths     = %w( /de/blog/tags/tag-1+tag-2 )                          
  article_paths  = %w( /de/blog/2000/1/1/an-article )

  collection_paths = blog_paths + category_paths + tags_paths
  all_paths = collection_paths + article_paths
  
  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end
  
  all_paths.each do |path|  
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_gets_page_cached
    end
  end
  
  category_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_assigns :category
    end
  end
  
  collection_paths.each do |path|    
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_assigns :articles
      it_renders_template :index    
    end
  end
                                  
  tags_paths.each do |path|    
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_assigns :tags, %(foo bar)
    end
  end
                                  
  article_paths.each do |path|    
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_assigns :article
      it_renders_template :show
    end
  end
end