require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ContentTest < ActiveSupport::TestCase
  with_common :a_section, :a_content

  # @content = Content.new :site_id => 1, :section_id => 1, :title => "this content's title",
  #                        :body => "*body*", :excerpt => "*excerpt*", :author => @author,
  #                        :published_at => @time_now

  describe 'Content' do
    it "acts as a taggable" do
      # FIXME implement matcher
      # Content.should act_as_taggable
    end

    it "acts as a role context for the author role" do
      # FIXME implement matcher
      # Content.should act_as_role_context(:roles => :author)
    end

    it "acts as a commentable" do
      # FIXME implement matcher
      # Content.should act_as_commentable
    end

    it "acts as versioned" do
      # FIXME implement matcher
      # Content.should act_as_versioned
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
      # FIXME implement matcher
      # Content.should instantiate_with_sti
    end

    it "has a permalink generated from the title" do
      # FIXME implement matcher
      # Content.should have_a_permalink(:title)
    end

    it "filters the excerpt and body" do
      # FIXME implement matcher
      # @content.should filter_column(:excerpt)
      # @content.should filter_column(:body)
    end

    it "has a comments counter" do
      # FIXME implement matcher
      # Content.should have_counter(:comments)
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
  end

  describe "validations" do
    it "validates presence of a title" do
      @content.should validate_presence_of(:title)
    end

    it "validates presence of a body" do
      @content.should validate_presence_of(:body)
    end

    it "validates presence of an author (through belongs_to_author)" do
      @content.should validate_presence_of(:author)
    end

    it "validates that the author is valid (through belongs_to_author)" do
      @content.author = User.new
      @content.valid?.should == false
    end

    it "validates the uniqueness of the permalink per site" do
      @content = Content.new
      @content.should validate_uniqueness_of(:permalink, :scope => :section_id)
    end
  end

  # CLASS METHODS

  describe "#find_published" do
    it "finds published articles" do
      @content.update_attributes! :published_at => 1.hour.ago
      Content.find_published(:all).should include(@content)
    end

    it "does not find unpublished articles" do
      @content.update_attributes! :published_at => nil
      Content.find_published(:all).should_not include(@content)
    end
  end

  describe "#find_in_time_delta" do
    it "finds articles in the given time delta" do
      published_at = date = 1.hour.ago
      delta = date.year, date.month, date.day
      @content.update_attributes! :published_at => published_at
      Content.find_in_time_delta(*delta).should include(@content)
    end

    it "#find_in_time_delta finds articles prior the given time delta" do
      published_at = 1.hour.ago
      date = 2.months.ago
      delta = date.year, date.month, date.day
      @content.update_attributes! :published_at => published_at
      Content.find_in_time_delta(*delta).should_not include(@content)
    end

    it "#find_in_time_delta finds articles after the given time delta" do
      published_at = 2.month.ago
      date = Time.zone.now
      delta = date.year, date.month, date.day
      @content.update_attributes! :published_at => published_at
      Content.find_in_time_delta(*delta).should_not include(@content)
    end
  end

  describe "#find_every" do
    it "does not apply the default_find_options (order) if :order option is given" do
      expectation do
        mock(Content).find_by_sql(/ORDER BY id/).returns [@content]
        Content.find :all, :order => :id
      end
    end

    it "applies the default_find_options (order) if :order option is not given" do
      expectation do
        mock(Content).find_by_sql(/ORDER BY #{Content.default_find_options[:order]}/).returns [@content]
        Content.find :all
      end
    end

    it "finds articles tagged with :tags if the option :tags is given" do
      expectation do
        mock(Content).find_options_for_find_tagged_with(['foo', 'bar'], RR.anything).returns({})
        Content.find :all, :tags => ['foo', 'bar']
      end
    end
  end

  # INSTANCE METHODS

  describe "#owner" do
    it "returns the section" do
      @content.owner.should == @section
    end
  end
  
  describe "#attributes=" do
    it "#attributes= calls update_categories if attributes include a :category_ids key" do
      mock(@content).update_categories.with([1, 2, 3])
      @content.attributes = { :category_ids => [1, 2, 3] }
    end
  end
  
  # FIXME actually diff something
  #
  # describe "#diff_against_version" do
  #   before do
  #     stub(HtmlDiff).diff
  #     @other = Content.new :body_html => 'body', :excerpt_html => 'excerpt'
  #     @content.body_html = 'body'
  #     @content.excerpt_html = 'excerpt'
  #     # stub(@content.versions).find_by_version(anything).returns @other
  #   end
  # 
  #   it "creates a diff" do
  #     expectation do
  #       mock(HtmlDiff).diff.with anything
  #       @content.diff_against_version(1)
  #     end
  #   end
  # 
  #   it "diffs excerpt_html + body_html" do
  #     [@content, @other].each do |target| [:body_html, :excerpt_html].each do |method|
  #       mock(target).stub!(method).returns method.to_s
  #     end end
  #     @content.diff_against_version(1)
  #   end
  # end

  describe "#comments_expired_at" do
    # FIXME use constants for comment_age!
    it "returns a date 1 day after the published_at date if comments expire after 1 day" do
      @content.comment_age = 1
      @content.comments_expired_at.should == @content.published_at + 1.day
    end

    it "returns the published_at date if comments are not allowed (i.e. expire after 0 days)" do
      @content.comment_age = 0
      @content.comments_expired_at.should == @content.published_at
    end

    it "returns a date in far future if comments never expire" do
      @content.comment_age = -1
      @content.comments_expired_at.should == 9999.years.from_now
    end
  end

  describe "#set_site" do 
    it "sets the site_id from the section" do
      @content.site_id = nil
      @content.send :set_site
      @content.site_id.should == @content.section.site_id
    end
  end
  
  describe "#update_categories updates the associated categories to match the given category ids" do
    before :each do
      @category = @content.categories.first
      @foo = Category.create! :title => 'foo', :section => @section
      @bar = Category.create! :title => 'bar', :section => @section
    end
  
    it 'removes associated categories that are not included in passed category_ids' do
      @content.send :update_categories, [@foo.id, @bar.id]
      @content.categories.should_not include(@category)
    end
  
    it 'assigns categories that are included in passed category_ids but not already associated' do
      @content.send :update_categories, [@foo.id, @bar.id]
      @content.categories.should include(@foo, @bar)
    end
  end
  
  describe "versioning" do
    it "does not create a new version if neither title, excerpt nor body attributes have changed" do
      @content.save_version?.should == false
    end
  
    it "creates a new version if the title attribute has changed" do
      @content.title = 'another title'
      @content.save_version?.should == true
    end
  
    it "creates a new version if the excerpt attribute has changed" do
      @content.excerpt = 'another excerpt'
      @content.save_version?.should == true
    end
  
    it "creates a new version if the body attribute has changed" do
      @content.body = 'another body'
      @content.save_version?.should == true
    end
  end
  
  describe "tagging" do
    it "works with quoted tags" do
      @content.tag_list = '"foo bar"'
      @content.save!
      @content.reload
      @content.tag_list.should == ['foo bar']
      @content.cached_tag_list.should == '"foo bar"'
    end
  end
end