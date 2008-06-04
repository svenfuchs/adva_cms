require File.dirname(__FILE__) + "/../spec_helper"

describe BlogController, 'feeds' do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :blog, :article, :category, :tag

    @blog.articles.stub!(:paginate_published_in_time_delta).and_return @articles
    @category.contents.stub!(:paginate_published_in_time_delta).and_return @articles
    @site.sections.stub!(:find).and_return @blog
  end
  
  articles_feed_paths = %w( /de/blog.atom
                            /de/blog/tags/foo+bar.atom )
                            
  comments_feed_paths = %w( /de/blog/comments.atom
                            /de/blog/2008/1/1/an-article.atom )

  articles_feed_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_renders_template 'index', :format => :atom
      it_gets_page_cached
    end
  end
  
  comments_feed_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_renders_template 'comments/comments', :format => :atom
      it_gets_page_cached
    end
  end
end