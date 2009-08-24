require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class NestedCategoriesTest < ActiveSupport::TestCase
  def setup
    super
    @page = Page.first
    @category = Category.create!(:title => 'fi', :section => @page)
    @child_category = Category.create!(:title => 'joensuu', :section => @page)
    @child_category.move_to_child_of(@category)

    @article_1 = @page.articles.build(:title => 'finland', :body => 'polar bears & penguins', :author => User.first).save!
    @article_2 = @page.articles.build(:title => 'joensuu', :body => 'north karelian capital', :author => User.first).save!
    @article_1 = Article.find_by_title('finland')
    @article_2 = Article.find_by_title('joensuu')

    @article_1.categories << @category
    @article_2.categories << @child_category
  end

  test 'all_contents returns a scope of all the contents of category and its descendants' do
    assert_equal [@article_1, @article_2], @category.all_contents
    assert_equal [@article_2], @child_category.all_contents
  end

  test 'all_contents returns categories of a certain section only' do
    # There is a 'a category' named category for a blog, a page and for a wiki,
    # we do not want it to return wiki or blog category contents
    category = Category.find_by_title('a category')
    category.all_contents.each do |content|
      content.should be_an(Article)
      content.section.should be_a(Page)
    end
  end
end