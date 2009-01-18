require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ContentHelperTest < ActiveSupport::TestCase
  include ContentHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::UrlHelper
  
  def setup
    super
    @site = Site.first
    @section = Section.first
    @article = @section.articles.find_published :first
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
    published_at_formatted(@article).should == 'January 1st'
  end

  test "#published_at_formatted returns a mdy formatted date 
        if the article was published before the current year" do
    previous_year = Time.now.utc.year - 1
    @article.published_at = Time.utc(previous_year, 1, 1)
    published_at_formatted(@article).should == "January 1st, #{previous_year}"
  end
  
  # link_to_admin_object

  test "#link_to_admin_object given the passed object is a Content 
        it returns a link to edit_admin_[content_type]_path" do
    stub(self).edit_admin_article_path.returns 'edit_admin_article_path'
    link_to_admin_object(@article).should =~ /edit_admin_article_path/
  end

  test "#link_to_admin_object given the passed object is a Section 
        it returns a link to admin_section_contents_path(object)" do
    stub(self).admin_section_contents_path.returns 'admin_section_contents_path'
    link_to_admin_object(@section) =~ /admin_section_contents_path/
  end

  test "#link_to_admin_object given the passed object is a Site 
        it returns a link to admin_site_path" do
    stub(self).admin_site_path.returns 'admin_site_path'
    link_to_admin_object(@site) =~ /admin_site_path/
  end

  # content_path
  
  test "#content_path given the content's section is a Blog it returns an article_path" do
    @article = Blog.first.articles.first
    mock(self).article_path.with(@article.section, @article.full_permalink)
    content_path(@article)
  end

  test "#content_path given the content's section is a Wiki it returns an wikipage_path" do
    @wikipage = Wiki.first.wikipages.first
    mock(self).wikipage_path.with(@wikipage.section, @wikipage.permalink, {})
    content_path(@wikipage)
  end
  
  test "#content_path given the content's section is a Section it returns an section_article_path" do
    mock(self).section_article_path.with(@article.section, @article.permalink, {})
    content_path(@article)
  end

  # content_url
  
  test "#content_url delegates to content_path and prepends the current protocol, host and port" do
    mock(self).content_path(@article, {}).returns '/path/to/content'
    content_url(@article).should == "http://#{@article.site.host}/path/to/content"
  end
end

class LinkToContentHelperTest < ActiveSupport::TestCase
  include ContentHelper
  
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::RecordIdentificationHelper
  
  def setup
    super
    @section = Section.first
    @article = @section.articles.find_published :first
    @category = @section.categories.first
    @tag = Tag.new :name => 'foo'
    
    stub(self).content_path.returns '/path/to/content#comments'
    stub(self).section_category_path.returns '/path/to/section/category'
    stub(self).section_tag_path.returns '/path/to/section/tag'
  end
  
  # link_to_content_comments_count
  
  test "#link_to_content_comments_count returns a link_to_content_comments" do
    # FIXME implement matcher
    # link_to_content_comments_count(@article).should have_tag('a[href=?]', '/path/to/content')
    link_to_content_comments_count(@article).should =~ /a href="\/path\/to\/content\#comments"/
  end

  test "#link_to_content_comments_count given the option :total is set 
        it returns a link_to_content_comments with the approved and total comments counts as a link text" do
    link_to_content_comments_count(@article, :total => true).should =~ /\d{2} \(\d{2}\)/
  end
  
  test "#link_to_content_comments_count given the option :total is not set 
        it returns a link_to_content_comments with the total comments count as a link text" do
    link_to_content_comments_count(@article).should =~ /\d{2}/
  end
  
  test "#link_to_content_comments_count given the content has no comments 
        it returns the option :alt as plain text" do
    stub(@article).approved_comments_count.returns 0
    link_to_content_comments_count(@article, :alt => 'no comments').should == 'no comments'
  end

  test "#link_to_content_comments_count given the content has no comments and no option :alt was passed 
        it returns 'none' as plain text" do
    stub(@article).approved_comments_count.returns 0
    link_to_content_comments_count(@article).should == 'none'
  end

  # link_to_content_comments

  test "#link_to_content_comments given a content it returns a link to content_path" do
    # FIXME implement matcher
    # link_to_content_comments(@article).should have_tag('a[href=?]', '/path/to/content')
    link_to_content_comments(@article).should == '<a href="/path/to/content#comments">1 Comment</a>'
  end

  test "#link_to_content_comments given a content and a comment it returns a link to content_path + comment anchor" do
    comment = @article.comments.first
    anchor = dom_id(comment)
    stub(self).content_path(@article, :anchor => anchor).returns "/path/to/content##{anchor}"
    link_to_content_comments(@article, comment).should == %(<a href="/path/to/content##{anchor}">1 Comment</a>)
  end

  test "#link_to_content_comments given the first arg is a String it uses the String as link text" do
    link_to_content_comments('link text', @article).should == '<a href="/path/to/content#comments">link text</a>'
  end

  test "#link_to_content_comments given the content has no approved comments and the content does not accept comments 
        it returns nil" do
    mock(@article).approved_comments_count.returns 0
    mock(@article).accept_comments?.returns false
    link_to_content_comments(@article).should == nil
  end
  
  # link_to_content_comment
  
  test "#link_to_content_comment inserts the comment's commentable to the args and calls link_to_content_comments" do
    link_to_content_comment(@article.comments.first).should == '<a href="/path/to/content#comments">1 Comment</a>'
  end
  
  # link_to_category
  
  test "#link_to_category links to the given category" do
    link_to_category(@category).should == %(<a href="/path/to/section/category">#{@category.title}</a>)
  end

  test "#link_to_category given the first argument is a String it uses the String as link text" do
    link_to_category('link text', @category).should == '<a href="/path/to/section/category">link text</a>'
  end

  # links_to_content_categories 
  
  test "#links_to_content_categories returns an array of links to the given content's categories" do
    links_to_content_categories(@article).should == ["<a href=\"/path/to/section/category\">#{@category.title}</a>"]
  end

  test "#links_to_content_categories returns nil if the content has no categories" do
    @article.categories.clear
    links_to_content_categories(@article).should == nil
  end

  # link_to_tag
  
  test "#link_to_tag links to the given tag" do
    link_to_tag(@section, @tag).should == '<a href="/path/to/section/tag">foo</a>'
  end

  test "#link_to_tag given the first argument is a String it uses the String as link text" do
    link_to_tag('link text', @section, @tag).should == '<a href="/path/to/section/tag">link text</a>'
  end
  
  # links_to_content_tags
  
  test "#links_to_content_tags returns an array of links to the given content's tags" do
    links_to_content_tags(@article).should == 
      ['<a href="/path/to/section/tag">foo</a>', '<a href="/path/to/section/tag">bar</a>']
  end

  test "returns nil if the content has no tags" do
    @article.tags.clear
    links_to_content_tags(@article).should == nil
  end

  # content_category_checkbox

  test "#content_category_checkbox given an Article 
        returns a checkbox named 'article[category_ids][]' with the id article_category_1" do
    result = content_category_checkbox(@article, @category)
    # FIXME implement matcher
    # result.should have_tag('input[type=?][name=?]', 'checkbox', 'article[category_ids][]')
    result.should =~ /<input.* id="article_category_\d*" name="article\[category_ids\]\[\]" type="checkbox"/
  end
  
  test "#content_category_checkbox given an Article that belongs to the given Category the checkbox is checked" do
    result = content_category_checkbox(@article, @category)
    # FIXME implement matcher
    # result.should have_tag('input[type=?][checked=?]', 'checkbox', 'checked')
    result.should =~ /checked/
  end
  
  test "#content_category_checkbox given an Article that does not belong to the given Category it the checkbox is not checked" do
    @article.categories.clear
    content_category_checkbox(@article, @category).should_not =~ /checked/
  end
end
