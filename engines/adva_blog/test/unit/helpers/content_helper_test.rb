require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module BlogTests
  class ContentHelperTest < ActionView::TestCase
    include ContentHelper
    include BlogHelper

    test "#content_path given the content's section is a Blog it returns a blog_path" do
      @article = Blog.first.articles.first
      content_path(@article).should =~ %r(/2008/1/1/a-blog-article)
    end
  end
end