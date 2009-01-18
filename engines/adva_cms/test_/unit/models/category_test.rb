require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class CategoryTest < ActiveSupport::TestCase
  with_common :a_section, :a_category

  describe 'Category' do
    it 'acts as a nested set' do
      # FIXME implement matcher
      # Category.should act_as_nested_set
    end

    it 'generates a permalink from the title' do
      @category.title = "a category's title"
      @category.permalink = nil
      @category.send :create_unique_permalink
      @category.permalink.should == 'a-category-s-title'
    end
  end

  describe 'Category associations:' do
    it "belongs to a section" do
      @category.should belong_to(:section)
    end
  
    it "has many contents" do
      @category.should have_many(:contents)
    end
  
    it "has many category_assignments" do
      @category.should have_many(:category_assignments)
    end
  end
  
  describe 'callbacks:' do
    it 'initializes the permalink before validation (if empty)' do
      Category.before_validation.should include(:create_unique_permalink)
    end
  end
  
  describe 'validations:' do
    it 'validates the presence of a section' do
      @category.should validate_presence_of(:section)
    end
  
    it 'validates the presence of a title' do
      @category.should validate_presence_of(:title)
    end
  
    it 'validates the uniqueness of the permalink per section' do
      @category.section = @section
      @category.should validate_uniqueness_of(:permalink, :scope => :section_id)
    end
  end
  
  # FIXME
  #
  # describe 'instance methods:' do
  #   it '#set_path should be specified'
  #   it '#update_child_paths usage + behaviour should be specified' # (this certainly can be done better)
  # end
end
