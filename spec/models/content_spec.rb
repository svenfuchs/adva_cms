require File.dirname(__FILE__) + '/../spec_helper'

describe Content do
  include Stubby
  
  before :each do
    scenario :user
    @content = Content.new :site_id => 1, :section_id => 1, :title => "this content's title", 
                           :body => "*body*", :excerpt => "*excerpt*", :author => stub_user
  end
  
  describe "class extensions:" do
    it "acts as a taggable"
    it "acts as a role context for the author role"
    it "acts as a commentable"
    it "acts as versioned"
    it "is configured to save a new version when the title, body or excerpt attribute changes"
    it "is configured to save up to 5 versions"
    it "ignores the columns cached_tag_list, assets_count and state"
    it "instantiates with single table inheritance"
    
    it "has a permalink generated from the title"do
      @content.send :create_unique_permalink
      @content.permalink.should == 'this-content-s-title'
    end
  
    it "filters the excerpt" do
      @content.should_receive(:filter).any_number_of_times.and_return 'textile_filter'
      @content.send :process_filters
      @content.excerpt_html.should == '<p><strong>excerpt</strong></p>'
    end
  
    it "filters the body" do      
      should_filter_column @content, :body
      # @content.should_receive(:filter).any_number_of_times.and_return 'textile_filter'
      # @content.send :process_filters
      # @content.body_html.should == '<p><strong>body</strong></p>'
    end
  end
  
  # TODO implement as matcher: 
  # @content.should filter_column(:body)
  def should_filter_column(object, column)
    object.send "#{column}=", '*strong*'
    object.should_receive(:filter).any_number_of_times.and_return 'textile_filter'
    object.send :process_filters
    object.send("#{column}_html").should == '<p><strong>strong</strong></p>'
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
    
    it "validates the uniqueness of the permalink per site" # do
    #   @content.should validate_uniqueness_of(:permalink, :scope => :site_id)
    # end
    
  end
  
  describe "class methods:" do
    it "#find_every returns records that are tagged with the passed tags when they are specified with a :tags option"
    it "#find_in_time_delta returns record within the given time delta"
    it "#with_published adds a scope so that finders only return published records"
    it "#with_time_delta adds a scope so that finders only return records published within the given time delta"
    it "#recognizes finders with a '_published' token in their name and adds the with_time_delta scope"
  end
  
  # moved here from article_spec 
  #
  # describe "#find_published" do
  #   it "finds published articles" do
  #     article = Article.create! @attributes.update(:published_at => 1.hour.ago)
  #     Article.find_published(:all).should include(article)
  #   end
  # 
  #   it "#find_published does not find unpublished articles" do
  #     article = Article.create! @attributes
  #     Article.find_published(:all).should_not include(article)
  #   end
  # end
  # 
  # describe "#find_in_time_delta" do
  #   it "finds articles in the given time delta" do
  #     published_at = date = 1.hour.ago
  #     delta = date.year, date.month, date.day
  #     article = Article.create! @attributes.update(:published_at => published_at)
  #     Article.find_in_time_delta(*delta).should include(article)
  #   end
  # 
  #   it "#find_in_time_delta finds articles prior the given time delta" do
  #     published_at = 1.hour.ago
  #     date = 2.months.ago
  #     delta = date.year, date.month, date.day
  #     article = Article.create! @attributes.update(:published_at => published_at)
  #     Article.find_in_time_delta(*delta).should_not include(Article.new)
  #   end
  # 
  #   it "#find_in_time_delta finds articles after the given time delta" do
  #     published_at = 2.month.ago
  #     date = Time.zone.now
  #     delta = date.year, date.month, date.day
  #     article = Article.create! @attributes.update(:published_at => published_at)
  #     Article.find_in_time_delta(*delta).should_not include(article)
  #   end
  # end
  
  # describe "#find_every" do
  #   it "does not apply the default_find_options (order) if :order option is given" do
  #     Article.should_receive(:find_by_sql).with(/ORDER BY id/).and_return [@article]
  #     Article.find :all, :order => :id
  #   end
  #   
  #   it "applies the default_find_options (order) if :order option is not given" do
  #     order = /ORDER BY #{Article.default_find_options[:order]}/
  #     Article.should_receive(:find_by_sql).with(order).and_return [@article]
  #     Article.find :all
  #   end
  # 
  #   it "finds articles tagged with :tags if the option :tags is given" do
  #     Article.should_receive :find_tagged_with
  #     Article.find :all, :tags => %w(foo bar)
  #   end
  # end  

  describe "instance methods:" do
    it "#owner returns the section"    
    
    it "#attributes= temporarily remembers passed category_ids" do
      @content.attributes = { :category_ids => [1, 2, 3] }
      @content.instance_variable_get(:@new_category_ids).should == [1, 2, 3]
    end
    
    it "#diff_against_version returns the diff (of excerpt and body) against the specified version"

    describe "#comments_expired_at" do
      it "returns a date 1 day after the published_at date if comments expire after 1 day"
      it "returns the published_at date if comments are not allowed (i.e. expire after 0 days)"
      it "returns something else? if comments never expire. hu?"
    end
    
    it "#set_site sets the site_id from the section"
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