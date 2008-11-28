scenario :wiki_with_wikipages do
  stub_scenario :empty_site

  @section = @wiki = stub_wiki
  @wikipage = stub_wikipage
  @wikipages = stub_wikipages
  @category = stub_category(:category)
  @categories = stub_categories

  Section.stub!(:find).and_return @wiki
  @site.sections.stub!(:find).and_return @wiki
  @site.sections.stub!(:root).and_return @wiki

  @wikipages.stub!(:total_entries).and_return 2

  @category.stub!(:contents).and_return(@wikipages)

  Category.stub!(:find).and_return @category
  Category.stub!(:find_by_path).and_return @category
  @wiki.categories.stub!(:find_by_path).and_return @category

  Tag.stub!(:find).and_return stub_tags(:all)
end
