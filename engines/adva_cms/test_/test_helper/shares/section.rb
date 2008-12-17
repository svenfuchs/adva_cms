class Test::Unit::TestCase
  share :an_empty_section do
    before do 
      @site = Site.make
      @section = Section.make :site => @site
    end
  end

  share :published_section_article do
    before do 
      @site = Site.make
      @section = Section.make :site => @site, :type => 'Section'
      @article = Article.make :site => @site, :section => @section, :published_at => Time.now
    end
  end
end