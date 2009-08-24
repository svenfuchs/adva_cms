require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class CategoryTest < ActiveSupport::TestCase
  def setup
    super
    @page = Page.first
    @category = @page.categories.first
    @new_category = Category.new(:section => @page, :title => 'a category', :parent => @category)
  end

  test 'acts as a nested set' do
    Category.should act_as_nested_set
  end

  test "has a permalink generated from the title" do
    Category.should have_permalink(:title)
  end

  test 'generates a permalink from the title' do
    @category.title = "a category's title"
    @category.permalink = nil
    @category.send :ensure_unique_url
    @category.permalink.should == 'a-categorys-title'
  end

  # ASSOCIATIONS

  test "belongs to a section" do
    @category.should belong_to(:section)
  end

  test "has many contents" do
    @category.should have_many(:contents)
  end

  test "has many categorizations" do
    @category.should have_many(:categorizations)
  end

  # VALIDATIONS

  test 'validates the presence of a section' do
    @category.should validate_presence_of(:section)
  end

  test 'validates the presence of a title' do
    @category.should validate_presence_of(:title)
  end

  test 'validates the uniqueness of the permalink per section' do
    @category.section = @page
    @category.should validate_uniqueness_of(:permalink, :scope => :section_id)
  end

  # CALLBACKS

  test "#update_paths moves a new category to a child of its parent and updates the category paths" do
    @new_category.save
    @new_category.should be_child_of(@category)
  end

  # FIXME
  #
  # describe 'instance methods:' do
  #   test '#set_path should be specified'
  #   test '#update_child_paths usage + behaviour should be specified' # (this certainly can be done better)
  # end
end
