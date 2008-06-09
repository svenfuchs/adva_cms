require File.dirname(__FILE__) + '/../spec_helper'

describe Section do
  include Matchers::ClassExtensions
  fixtures :sites, :sections
  
  before :each do 
    @site = sites(:site_1)
    @home = sections(:home)
    @about = sections(:about)
    @location = sections(:location)
    
    @section = Section.new :title => 'section'
    @section.site = @site
  end
  
  describe "class extensions:" do
    it "acts as a role context for the moderator role" do
      Section.should act_as_role_context(:roles => :moderator)
    end
    
    it "has default permissions for articles and categories" do
      Section.default_permissions.should == 
        { :category => { :show => :moderator, :create => :moderator, :update => :moderator, :delete => :moderator }, 
          :article  => { :show => :moderator, :create => :moderator, :update => :moderator, :delete => :moderator } }
    end
    
    it "serializes its actual permissions" do
      Section.serialized_attributes.should include('permissions')
    end
  
    it "has an option :articles_per_page" do
      lambda{ @section.articles_per_page }.should_not raise_error
    end
  
    it "serialize the option :articles_per_page to the database" do
      @section.instance_variable_set :@options, nil
      save_and_reload @section
      @section.articles_per_page = 20
      save_and_reload @section
      @section.articles_per_page.should == 20
    end
    
    it "has a permalink generated from the title" do
      @section.send :create_unique_permalink
      @section.permalink.should == 'section'
    end
    
    it "acts as a nested set" do
      Section.should act_as_nested_set
    end
    
    it "acts as a commentable" do
      Content.should act_as_commentable
    end
    
    it "instantiates with single table inheritance" do
      Content.should instantiate_with_sti
    end
  end
  
  describe "associations:" do
    it "belongs to a site" do
      @section.should belong_to(:site)
    end
  
    it "has many articles" do
      @section.should have_many(:articles)
    end

    it "has many categories" do
      @section.should have_many(:categories)
    end
  
    describe "the articles association" do
      it "#primary returns the topmost published article" do
        article = mock 'article'
        Article.should_receive(:find_published).with(:first, {:order => :position}).and_return article
        @section.articles.primary.should == article
      end
      
      it "#permalinks returns the permalinks of all published articles" do
        articles = [1, 2].map {|i| mock 'article', :permalink => "article-#{i}" } 
        Article.should_receive(:find_published).with(:all).and_return articles
        @section.articles.permalinks.should == ['article-1', 'article-2']
      end
    end
  
    describe "the categories association" do
      it "#roots returns all categories that do not have a parent category" do
        @section.categories.should_receive(:find).with(:all, hash_including(:conditions => {:parent_id => nil}))
        @section.categories.roots
      end
    end
  end
  
  describe "callbacks:" do
    it "sets the path before validation" do
      Section.before_validation.should include(:set_path)
    end
    
    it "sets the comment age before validation" do
      Section.before_validation.should include(:set_comment_age)
    end
    
    it "generates the permalink before validation" do
      Section.before_validation.should include(:create_unique_permalink)
    end
  end
  
  describe "validations:" do
    it "validates the presence of a site" do
     @section.should validate_presence_of(:site)
    end
    
    it "validates the presence of a title" do
      @section.should validate_presence_of(:title)
    end
    
    it "validates the uniqueness of the permalink per site" do
      @section.should validate_uniqueness_of(:permalink) # :scope => :site_id
    end
  end
  
  describe "class methods:" do
    it ".types returns a collection of registered Section types" do
      Section.types.should include('Section')
    end
    
    it ".register_type adds a Section type to the type collection" do
      Section.register_type('Galerie')
      Section.types.should include('Galerie')
    end
    
    it ".paths returns all non-empty paths for the given host" do
      Section.paths('test.host').sort[0..1].== ["about", "about/location"]
    end
    
    it ".find_by_host_and_path should probably be replaced by Site.find_by_host etc.?"
  end
  
  describe "public instance methods" do
    it "#type returns 'Section' for a Section" do
      s = Section.create! :title => 'title', :site => @site
      s.type.should == 'Section'
    end
    
    it "#owner returns the site" do
      @section.owner.should == @site
    end
    
    it "#tag_counts returns the tag_counts for this site's content's tags" do
      Content.should_receive(:tag_counts).with :conditions => "section_id = #{@section.id}"
      @section.tag_counts
    end
    
    it "#render_options should be specified but looks pretty uncomprehensible right now"
    
    it "#root_section? returns true if this section is the site's root section" do
      @section.site = @site
      @site.sections.stub!(:root).and_return @section
      @section.root_section?.should be_true
    end
    
    it "#accept_comments? is true when comments are not 'not-allowed' (-1) (see comment_expiration_options)" do
      @section.stub!(:comment_age).and_return 0
      @section.accept_comments?.should be_true
    end
  
    it "#accept_comments? is false when comments are 'not-allowed' (-1) (see comment_expiration_options)" do
      @section.stub!(:comment_age).and_return -1
      @section.accept_comments?.should be_false
    end
  end
  
  describe "protected instance methods" do
    it "#set_comment_age sets the comment_age to -1 if it's not already set" do
      @section.comment_age = nil
      @section.send :set_comment_age
      @section.comment_age.should_not be_nil
    end
    
    it "#set_comment_age does not change an already set comment_age" do
      @section.comment_age = 99
      @section.send :set_comment_age
      @section.comment_age.should == 99
    end
    
    it "#set_path sets the section's path" do
      @section.stub!(:build_path).and_return 'path'
      @section.send :set_path
      @section.path.should_not be_nil
    end
    
    it "#build_path builds a path by joining self and anchestor permalinks with '/'" do
      @location.send(:build_path).should == "home/about/location"    
    end  
  end
  
  private
  
    def save_and_reload(record)
      record.save
      record.reload
    end
end