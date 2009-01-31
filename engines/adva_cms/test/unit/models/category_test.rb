require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class CategoryTest < ActiveSupport::TestCase
  def setup
    super
    @section = Section.first
    @category = @section.categories.first
  end

  test 'acts as a nested set' do
    Category.should act_as_nested_set
  end

  test 'generates a permalink from the title' do
    @category.title = "a category's title"
    @category.permalink = nil
    @category.send :create_unique_permalink
    @category.permalink.should == 'a-category-s-title'
  end
  
  # ASSOCIATIONS

  test "belongs to a section" do
    @category.should belong_to(:section)
  end

  test "has many contents" do
    @category.should have_many(:contents)
  end

  test "has many category_assignments" do
    @category.should have_many(:category_assignments)
  end
  
  # CALLBACKS
  
  test 'initializes the permalink before validation (if empty)' do
    Category.before_validation.should include(:create_unique_permalink)
  end
  
  # VALIDATIONS
  
  test 'validates the presence of a section' do
    @category.should validate_presence_of(:section)
  end

  test 'validates the presence of a title' do
    @category.should validate_presence_of(:title)
  end

  test 'validates the uniqueness of the permalink per section' do
    @category.section = @section
    @category.should validate_uniqueness_of(:permalink, :scope => :section_id)
  end
  
  # FIXME
  #
  # describe 'instance methods:' do
  #   test '#set_path should be specified'
  #   test '#update_child_paths usage + behaviour should be specified' # (this certainly can be done better)
  # end
end
