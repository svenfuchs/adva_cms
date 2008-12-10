class Test::Unit::TestCase
  share :an_empty_blog do
    before do 
      @site = Site.make
      @section = Section.make :site => @site, :type => 'Blog'
    end
  end

  share :published_blog_article do
    before do 
      @site = Site.make
      @section = Section.make :site => @site, :type => 'Blog'
      @article = Article.make :site => @site, :section => @section, :published_at => Time.now
    end
  end
end