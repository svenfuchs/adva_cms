require File.dirname(__FILE__) + '/../spec_helper'

describe Category do
  include Matchers::ClassExtensions
  
  before :each do 
    @category = Category.new :title => "a category's permalink"
  end
  
  describe 'class extensions' do
    it 'acts as a nested set' do
      Category.should act_as_nested_set
    end
    
    it 'generates a permalink from the title' do
      @category.send :create_unique_permalink
      @category.permalink.should == 'a-category-s-permalink'
    end
  end
  
  describe 'associations:' do
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
    it 'sets the path before validation' do
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
      @category.should validate_uniqueness_of(:permalink) # :scope => :section_id
    end    
  end
  
  describe 'class methods:' do
    it '.find_all_by_host should probably be replaced by Site.find_by_host.categories'
  end
  
  describe 'instance methods:' do
    it '#set_path should be specified'
    it '#update_child_paths usage + behaviour should be specified' # (this certainly can be done better)
  end
  
end