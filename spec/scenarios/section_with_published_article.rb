scenario :section_with_published_article do
  scenario :empty_site

  @section = stub_section
  @article = stub_article
  @articles = stub_articles

  Section.stub!(:find).and_return @section
  @site.sections.stub!(:root).and_return @section
  @section.articles.stub!(:permalinks).and_return ['an-article']
end