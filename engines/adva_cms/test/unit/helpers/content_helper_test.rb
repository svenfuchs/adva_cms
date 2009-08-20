require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ContentHelperTest < ActionView::TestCase
  include ContentHelper
  include ResourceHelper
  attr_reader :controller

  def setup
    super
    @page = Page.find_by_title 'a page'
    @site = @page.site
    @article = @page.articles.published(:limit => 1).first
    @controller = Class.new { def controller_path; 'articles' end }.new
  end

  # published_at_formatted

  test "#published_at_formatted returns 'not published'
        if the article is not published" do
    @article.published_at = nil
    published_at_formatted(@article).should == 'not published'
  end

  test "#published_at_formatted returns a short formatted date
        if the article was published in the current year" do
    @article.published_at = Time.utc(Time.now.utc.year, 1, 1)
    published_at_formatted(@article).should == '01 Jan 00:00'
  end

  test "#published_at_formatted returns a mdy formatted date
        if the article was published before the current year" do
    previous_year = Time.now.utc.year - 1
    @article.published_at = Time.utc(previous_year, 1, 1)
    published_at_formatted(@article).should == "January 01, #{previous_year} 00:00"
  end
end

class LinkToContentHelperTest < ActionView::TestCase
  include ContentHelper

  def setup
    super
    @page = Page.first
    @article = @page.articles.find_by_title 'a page article'
    @category = @page.categories.first
    @tag = Tag.new :name => 'foo'

    stub(self).page_category_path.returns '/path/to/page/category'
    stub(self).page_tag_path.returns '/path/to/page/tag'
  end
  
  # content_status
  
  test "#content_status returns an empty span if passed object does not respond_to published?" do
    content_status(Object.new).should == %(<span>&nbsp;</span>)
  end
  
  test "#content_status returns span with published title and alt if passed object is published" do
    content_status(@article).should == %(<span title='Published' alt='Published' class='status published'>Published</span>)
  end
  
  test "#content_status returns span with pending title and alt if passed object is not published" do
    @article.stubs(:published?).returns false
    content_status(@article).should == %(<span title='Pending' alt='Pending' class='status pending'>Pending</span>)
  end
  
  # link_to_category

  test "#link_to_category links to the given category" do
    link_to_category(@category).should == %(<a href="/path/to/page/category">#{@category.title}</a>)
  end

  test "#link_to_category given the first argument is a String it uses the String as link text" do
    link_to_category('link text', @category).should == '<a href="/path/to/page/category">link text</a>'
  end

  # links_to_content_categories

  test "#links_to_content_categories returns an array of links to the given content's categories" do
    links_to_content_categories(@article).should include("<a href=\"/path/to/page/category\">#{@category.title}</a>")
  end

  test "#links_to_content_categories returns nil if the content has no categories" do
    @article.categories.clear
    links_to_content_categories(@article).should be_nil
  end

  # link_to_tag

  test "#link_to_tag links to the given tag" do
    link_to_tag(@page, @tag).should == '<a href="/path/to/page/tag">foo</a>'
  end

  test "#link_to_tag given the first argument is a String it uses the String as link text" do
    link_to_tag('link text', @page, @tag).should == '<a href="/path/to/page/tag">link text</a>'
  end

  # links_to_content_tags

  test "#links_to_content_tags returns an array of links to the given content's tags" do
    links_to_content_tags(@article).should ==
      ['<a href="/path/to/page/tag">foo</a>', '<a href="/path/to/page/tag">bar</a>']
  end

  test "returns nil if the content has no tags" do
    @article.tags.clear
    links_to_content_tags(@article).should be_nil
  end

  # content_category_checkbox

  test "#content_category_checkbox given an Article
        returns a checkbox named 'article[category_ids][]' with the id article_category_1" do
    result = content_category_checkbox(@article, @category)
    result.should have_tag('input[type=?][name=?]', 'checkbox', 'article[category_ids][]')
  end

  test "#content_category_checkbox given an Article that belongs to the given Category the checkbox is checked" do
    result = content_category_checkbox(@article, @category)
    result.should have_tag('input[type=?][checked=?]', 'checkbox', 'checked')
  end

  test "#content_category_checkbox given an Article that does not belong to the given Category it the checkbox is not checked" do
    @article.categories.clear
    content_category_checkbox(@article, @category).should_not =~ /checked/
  end
end
