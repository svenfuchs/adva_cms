require File.dirname(__FILE__) + '/../spec_helper'

describe Category do
  before :each do 
    @category = Category.new :title => "a category's permalink"
  end
  
  it "should belong to a section" do
    @category.should belong_to(:section)
  end
  
  it "should have many contents" do
    @category.should have_many(:contents)
  end
  
  it "should have many category_assignments" do
    @category.should have_many(:category_assignments)
  end
  
  it "should generate the permalink attribute from the title" do
    @category.send :create_unique_permalink
    @category.permalink.should == 'a-category-s-permalink'
  end
  
  it "should have permalink generation hooked up before validation" do
    Category.before_validation.should include(:create_unique_permalink)
  end
end