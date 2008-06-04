require File.dirname(__FILE__) + '/../spec_helper'

describe Section do
  fixtures :sites, :sections
  
  before :each do 
    @site = sites(:site_1)
    @home = sections(:home)
    @about = sections(:about)
    @location = sections(:location)
    
    @section = Section.new :title => 'section'
  end
  
  describe "#paths" do
    it "should return all non-empty paths for the given host" do
      Section.paths('test.host').sort[0..1].should == ["about", "about/location"]
    end
  end
  
  it "should return 'Section' as a type for a Section" do
    s = Section.create! :title => 'title', :site => @site
    s.type.should == 'Section'
  end
  
  it "should generate the permalink attribute from the title" do
    @section.send :create_unique_permalink
    @section.permalink.should == 'section'
  end
  
  it "should have permalink generation hooked up before validation" do
    Section.before_validation.should include(:create_unique_permalink)
  end
  
  it "should build a path by joining self and anchestor permalinks with '/'" do
    @location.send(:build_path).should == "home/about/location"    
  end

  it "should have many categories" do
    @section.should have_many(:categories)
  end
  
  it "should have many comments" do
    @section.should have_many(:comments)
  end
  
  it "should have many approved_comments" do
    @section.should have_many(:approved_comments)
  end
  
  it "should have many unapproved_comments" do
    @section.should have_many(:unapproved_comments)
  end
  
  it "should have many articles" do
    @section.should have_many(:articles)
  end
  
  describe "the articles collection" do
    it "#primary should return the topmost article as the primary article" do
      article = mock 'article'
      Article.should_receive(:find_published).with(:first, {:order => :position}).and_return article
      @section.articles.primary.should == article
    end
    
    it "#permalinks should return the permalinks of all articles in this section" do
      articles = [1, 2].map {|i| mock 'article', :permalink => "article-#{i}" } 
      Article.should_receive(:find_published).with(:all).and_return articles
      @section.articles.permalinks.should == ['article-1', 'article-2']
    end
  end
  
  it "should accept comments when comments are allowed" do
    @section.stub!(:comment_age).and_return 0
    @section.accept_comments?.should be_true
  end
  
  it "should not accept comments when comments are not allowed" do
    @section.stub!(:comment_age).and_return -1
    @section.accept_comments?.should be_false
  end
end