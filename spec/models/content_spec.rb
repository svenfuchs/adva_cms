require File.dirname(__FILE__) + '/../spec_helper'

describe Content do
  include Stubby
  
  before :each do
    scenario :user
    
    @content = Content.new :site_id => 1, :section_id => 1, :title => "this content's title", 
                           :body => "*body*", :excerpt => "*excerpt*", :author => stub_user
    # @section = sections('blog')
    # @category = categories('programming')
  end
  
  it "should have many assets" do
    @content.should have_many(:assets)
  end
  
  it "should have many asset_assignments" do
    @content.should have_many(:asset_assignments)
  end
  
  it "should have many categories" do
    @content.should have_many(:categories)
  end
  
  it "should have many category_assignments" do
    @content.should have_many(:category_assignments)
  end
  
  # TODO add various validations
  
  it "should validate presence of author" do
    @content.should validate_presence_of(:author)
  end
  
  it "should generate the permalink attribute from the title" do
    @content.send :create_unique_permalink
    @content.permalink.should == 'this-content-s-title'
  end
  
  it "should have permalink generation hooked up before validation" do
    Content.before_validation.should include(:create_unique_permalink)
  end
  
  it "should apply filters to the excerpt" do
    @content.should_receive(:filter).any_number_of_times.and_return 'textile_filter'
    @content.send :process_filters
    @content.excerpt_html.should == '<p><strong>excerpt</strong></p>'
  end
  
  it "should apply filters to the body" do
    @content.should_receive(:filter).any_number_of_times.and_return 'textile_filter'
    @content.send :process_filters
    @content.body_html.should == '<p><strong>body</strong></p>'
  end
  
  it "should apply filters before save" do
    Content.before_save.should include(:process_filters)
  end
  
  it "should not create a new version if neither title, excerpt nor body attributes have changed" do
    @content.save!
    @content.save_version?.should be_false
  end
  
  it "should create a new version if the title attribute has changed" do
    @content.save!
    @content.title = 'another title'
    @content.save_version?.should be_true
  end
  
  it "should create a new version if the excerpt attribute has changed" do
    @content.save!
    @content.excerpt = 'another excerpt'
    @content.save_version?.should be_true
  end
  
  it "should create a new version if the body attribute has changed" do
    @content.save!
    @content.body = 'another body'
    @content.save_version?.should be_true
  end
  
  it "should temporarily remember assigned category_ids when passed to :attributes=" do
    @content.attributes = { :category_ids => [1, 2, 3] }
    @content.instance_variable_get(:@new_category_ids).should == [1, 2, 3]
  end
  
  it "should save assigned categories after save" do
    Content.after_save.should include(:save_categories)
  end

end