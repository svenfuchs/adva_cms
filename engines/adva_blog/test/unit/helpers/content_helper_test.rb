require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module BlogTests
  class ContentHelperTest < ActionView::TestCase
    include ContentHelper
    include ResourceHelper
    include BlogHelper
    attr_accessor :controller
    
    def setup
      @controller = Class.new { def controller_path; 'articles' end }.new
    end

    test "#show_path given the content's section is a Blog it returns a blog_article_path" do
      @article = Blog.first.articles.first
      show_path(@article).should =~ %r(/2008/1/1/a-blog-article)
    end
  end
end