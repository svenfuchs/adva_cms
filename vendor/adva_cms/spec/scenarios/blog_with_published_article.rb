scenario :blog_with_published_article do
  scenario :empty_site

  @section = @blog = stub_blog
  @article = stub_article
  @articles = stub_articles
  @category = stub_category(:category)
  @categories = stub_categories

  @article.stub!(:[]).with('type').and_return 'Article' # TODO add #with to Stubby?

  Article.stub!(:find).and_return @article
  @category.stub!(:contents).and_return(@articles)
  @category.contents.stub!(:paginate_published_in_time_delta).and_return @articles
  @blog.articles.stub!(:paginate_published_in_time_delta).and_return @articles
  @blog.articles.stub!(:permalinks).and_return ['an-article']

  Category.stub!(:find).and_return @category
  Category.stub!(:find_by_path).and_return @category

  Tag.stub!(:find).and_return stub_tags(:all)

  Section.stub!(:find).and_return @blog
  @site.sections.stub!(:find).and_return @blog
  @site.sections.stub!(:root).and_return @blog
end