class Test::Unit::TestCase
  def valid_section_params
    { :title      => 'the section title',
      :type       => 'Section' }
  end

  share :valid_section_params do
    before do
      @params = { :section => valid_section_params }
    end
  end
  
  share :invalid_section_params do
    before do
      @params = { :section => valid_section_params.update(:title => '') }
    end
  end

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