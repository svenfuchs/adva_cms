require File.dirname(__FILE__) + '/../spec_helper'

describe Content do
  include Stubby
  include Matchers::ClassExtensions
  
  before :each do
    scenario :site, :section, :user
    @time_now = Time.zone.now
    @content = Content.new :site_id => 1, :section_id => 1, :title => "this content's title", 
                           :body => "*body*", :excerpt => "*excerpt*", :author => stub_user,
                           :published_at => @time_now
  end
  
  describe "class extensions:" do
    it "acts as a taggable" do
      Content.should act_as_taggable
    end
    
    it "acts as a role context for the author role" do
      Content.should act_as_role_context(:roles => :author)
    end
    
    it "acts as a commentable" do
      Content.should act_as_commentable
    end
    
    it "acts as versioned" do
      Content.should act_as_versioned
    end
    
    it "is configured to save a new version when the title, body or excerpt attribute changes" do
      Content.tracked_attributes.should == ["title", "body", "excerpt"]
    end
    
    it "is configured to save up to 5 versions" do
      Content.max_version_limit.should == 5
    end
    
    it "ignores the columns cached_tag_list, assets_count and state" do
      defaults = ["id", "type", "version", "lock_version", "versioned_type"]
      Content.non_versioned_columns.should == defaults + ["cached_tag_list", "assets_count", "state"]
    end
    
    it "instantiates with single table inheritance" do
      Content.should instantiate_with_sti
    end
    
    it "has a permalink generated from the title" do
      Content.should have_a_permalink(:title)
    end
  
    it "filters the excerpt" do
      @content.should filter_column(:excerpt)
    end
  
    it "filters the body" do      
      @content.should filter_column(:body)
    end
  end
  
  describe "associations" do
    it "belongs to a site" do
      @content.should belong_to(:site)
    end
    
    it "belongs to a section" do
      @content.should belong_to(:section)
    end
    
    it "belongs to an author" do
      @content.should belong_to(:author)
    end
    
    it "has many assets" do
      @content.should have_many(:assets)
    end
  
    it "has many asset_assignments" do
      @content.should have_many(:asset_assignments)
    end
  
    it "has many categories" do
      @content.should have_many(:categories)
    end
  
    it "has many category_assignments" do
      @content.should have_many(:category_assignments)
    end
  end

  describe "callbacks" do
    it "sets the site before validation" do
      Content.before_validation.should include(:set_site)
    end
    
    it "generates the permalink before validation" do
      Content.before_validation.should include(:create_unique_permalink)
    end
    
    it "apply filters before save" do
      Content.before_save.should include(:process_filters)
    end
    
    it "saves new category assignments after save" do
      Content.after_save.should include(:save_categories)
    end 
  end  
  
  describe "validations" do
    it "validate presence of a title" do
      @content.should validate_presence_of(:title)
    end
  
    it "validate presence of a body" do
      @content.should validate_presence_of(:body)
    end
  
    it "validate presence of an author (through belongs_to_author)" do
      @content.should validate_presence_of(:author)
    end
    
    it "validates the uniqueness of the permalink per site" do
      @content.should validate_uniqueness_of(:permalink) # :scope => :site_id
    end
    
  end
  
  describe "class methods:" do
    before :each do
      @attributes = {:title => 'title', :body => 'body', :section => stub_section, :author => stub_user}
    end
    
    describe "#find_published" do
      it "finds published articles" do
        article = Content.create! @attributes.update(:published_at => 1.hour.ago)
        Content.find_published(:all).should include(article)
      end
  
      it "#find_published does not find unpublished articles" do
        article = Content.create! @attributes
        Content.find_published(:all).should_not include(article)
      end
    end

    describe "#find_in_time_delta" do
      it "finds articles in the given time delta" do
        published_at = date = 1.hour.ago
        delta = date.year, date.month, date.day
        article = Content.create! @attributes.update(:published_at => published_at)
        Content.find_in_time_delta(*delta).should include(article)
      end
  
      it "#find_in_time_delta finds articles prior the given time delta" do
        published_at = 1.hour.ago
        date = 2.months.ago
        delta = date.year, date.month, date.day
        article = Content.create! @attributes.update(:published_at => published_at)
        Content.find_in_time_delta(*delta).should_not include(Content.new)
      end
  
      it "#find_in_time_delta finds articles after the given time delta" do
        published_at = 2.month.ago
        date = Time.zone.now
        delta = date.year, date.month, date.day
        article = Content.create! @attributes.update(:published_at => published_at)
        Content.find_in_time_delta(*delta).should_not include(article)
      end
    end    
    
    describe "#find_every" do
      it "does not apply the default_find_options (order) if :order option is given" do
        Content.should_receive(:find_by_sql).with(/ORDER BY id/).and_return [@article]
        Content.find :all, :order => :id
      end
    
      it "applies the default_find_options (order) if :order option is not given" do
        order = /ORDER BY #{Content.default_find_options[:order]}/
        Content.should_receive(:find_by_sql).with(order).and_return [@article]
        Content.find :all
      end
  
      it "finds articles tagged with :tags if the option :tags is given" do
        Content.should_receive(:find_options_for_find_tagged_with).and_return({})
        Content.find :all, :tags => %w(foo bar)
      end
    end
  end
  
  describe "instance methods:" do
    it "#owner returns the section" do
      @content.stub!(:section).and_return @section
      @content.owner.should == @section
    end
    
    it "#attributes= temporarily remembers passed category_ids" do
      @content.attributes = { :category_ids => [1, 2, 3] }
      @content.instance_variable_get(:@new_category_ids).should == [1, 2, 3]
    end
    
    describe "#diff_against_version" do
      before :each do
        HtmlDiff.stub!(:diff)
        @other = Content.new :body_html => 'body', :excerpt_html => 'excerpt'
        @content.body_html = 'body'
        @content.excerpt_html = 'excerpt'
        @content.versions.stub!(:find_by_version).and_return @other
      end
      
      it "creates a diff" do
        HtmlDiff.should_receive(:diff)
        @content.diff_against_version(1)
      end
      
      it "diffs excerpt_html + body_html" do
        [@content, @other].each do |target| [:body_html, :excerpt_html].each do |method|
          target.should_receive(method).and_return method.to_s
        end end
        @content.diff_against_version(1)
      end
    end

    describe "#comments_expired_at" do
      it "returns a date 1 day after the published_at date if comments expire after 1 day" do
        @content.stub!(:comment_age).and_return 1
        @content.comments_expired_at.to_date.should == 1.day.from_now.to_date
      end
      
      it "returns the published_at date if comments are not allowed (i.e. expire after 0 days)" do
        @content.stub!(:comment_age).and_return 0
        @content.comments_expired_at.to_date.should == @time_now.to_date
      end
      
      it "returns something else? if comments never expire. hu?" do
        @content.stub!(:comment_age).and_return -1
        @content.comments_expired_at.should == 9999.years.from_now
      end
    end
    
    it "#set_site sets the site_id from the section" do
      @content.section.should_receive(:site_id)
      @content.should_receive(:site_id=)
      @content.send :set_site
    end
    
    it "#save_categories makes sure that the associated categories match the new category ids"
  end
  
  describe "versioning" do
    it "does not create a new version if neither title, excerpt nor body attributes have changed" do
      @content.save!
      @content.save_version?.should be_false
    end
  
    it "creates a new version if the title attribute has changed" do
      @content.save!
      @content.title = 'another title'
      @content.save_version?.should be_true
    end
  
    it "creates a new version if the excerpt attribute has changed" do
      @content.save!
      @content.excerpt = 'another excerpt'
      @content.save_version?.should be_true
    end
  
    it "creates a new version if the body attribute has changed" do
      @content.save!
      @content.body = 'another body'
      @content.save_version?.should be_true
    end
  end

end