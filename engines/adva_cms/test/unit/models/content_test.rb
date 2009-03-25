require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ContentTest < ActiveSupport::TestCase
  def setup
    super
    @page = Page.first
    @content = @page.articles.first
    @content_attributes = { :title => 'A new content', :body => 'body',:section => @page, :author => User.first }
  end

  test "acts as a taggable" do
    Content.should act_as_taggable
  end
  
  test "acts as a role context for the author role" do
    Content.should act_as_role_context(:roles => :author)
  end
  
  test "acts as versioned" do
    Content.versioned_attributes.should_not be_empty
  end
  
  test "is configured to save a new version when the title, body or excerpt attribute changes" do
    Content.versioned_attributes.should == [ :title, :body, :excerpt, :body_html, :excerpt_html ]
  end
  
  test "is configured to save up to 5 versions" do
    Content.max_version_limit.should == 5
  end
  
  test "instantiates with single table inheritance" do
    Content.should instantiate_with_sti
  end
  
  test "has a permalink generated from the title" do
    Content.should have_permalink(:title)
  end
  
  test "filters the excerpt and body" do
    @content.should filter_column(:excerpt)
    @content.should filter_column(:body)
  end
  
  test "has many comments" do
    Content.should have_many_comments
  end
  
  test "has a comments counter" do
    Content.should have_counter(:comments)
  end
  
  # ASSOCIATIONS
  
  test "belongs to a site" do
    @content.should belong_to(:site)
  end
  
  test "belongs to a section" do
    @content.should belong_to(:section)
  end
  
  test "belongs to an author" do
    @content.should belong_to(:author)
  end
  
  test "has many assets" do
    @content.should have_many(:assets)
  end
  
  test "has many asset_assignments" do
    @content.should have_many(:asset_assignments)
  end
  
  test "has many categories" do
    @content.should have_many(:categories)
  end
  
  test "has many categorizations" do
    @content.should have_many(:categorizations)
  end
  
  # CALLBACKS
  
  test "sets the site before validation" do
    Content.before_validation.should include(:set_site)
  end
  
  test "apply filters before save" do
    Content.before_save.should include(:process_filters)
  end
  
  # VALIDATIONS
  
  test "validates presence of a title" do
    @content.should validate_presence_of(:title)
  end
  
  test "validates presence of a body" do
    @content.should validate_presence_of(:body)
  end
  
  # SCOPES
  
  test "published scope returns published articles" do
    Content.published.map(&:published?).uniq.should == [true]
  end
  
  test "published scope given a :year option returns articles published in that year" do
    contents = Content.published('2008')
    years = contents.map(&:published_at).map(&:year).uniq
    years.should == [2008]
  end
  
  test "published scope given :year and :month options returns articles published in that month" do
    contents = Content.published('2008', '1')
    months = contents.map(&:published_at).map { |d| [d.year, d.month] }.uniq.flatten
    months.should == [2008, 1]
  end
  
  test "published scope given :year, :month and day options returns articles published on that day" do
    contents = Content.published('2008', '1', '1')
    months = contents.map(&:published_at).map { |d| [d.year, d.month, d.day] }.uniq.flatten
    months.should == [2008, 1, 1]
  end

  # FIXME delete these?
  # # CLASS METHODS
  # 
  # test "#find_published finds published articles" do
  #   @content.update_attributes! :published_at => 1.hour.ago
  #   Content.find_published(:all).should include(@content)
  # end
  # 
  # test "#find_published does not find unpublished articles" do
  #   @content.update_attributes! :published_at => nil
  #   Content.find_published(:all).should_not include(@content)
  # end
  # 
  # test "#find_in_time_delta finds articles in the given time delta" do
  #   published_at = date = 1.hour.ago
  #   delta = date.year, date.month, date.day
  #   @content.update_attributes! :published_at => published_at
  #   Content.find_in_time_delta(*delta).should include(@content)
  # end
  # 
  # test "#find_in_time_delta finds articles prior the given time delta" do
  #   published_at = 1.hour.ago
  #   date = 2.months.ago
  #   delta = date.year, date.month, date.day
  #   @content.update_attributes! :published_at => published_at
  #   Content.find_in_time_delta(*delta).should_not include(@content)
  # end
  # 
  # test "#find_in_time_delta finds articles after the given time delta" do
  #   published_at = 2.month.ago
  #   date = Time.zone.now
  #   delta = date.year, date.month, date.day
  #   @content.update_attributes! :published_at => published_at
  #   Content.find_in_time_delta(*delta).should_not include(@content)
  # end
  # 
  # INSTANCE METHODS
  
  test "#owner returns the section" do
    @content.owner.should == @page
  end
  
  # published_month
  
  test '#published_month returns a time object for the first day of the month the content was published in' do
    @content.published_month.should == Time.local(@content.published_at.year, @content.published_at.month, 1)
  end
  
  # draft? 
  
  test '#draft? returns true when the content has not published_at date' do
    @content.published_at = nil
    @content.draft?.should be_true
  end
  
  test '#draft? returns false when the content has a published_at date' do
    @content.published_at = 1.days.ago
    @content.draft?.should be_false
  end
  
  # published?
  
  test "#published? returns true when published_at equals the current time" do
    @content.published_at = Time.zone.now
    @content.published?.should be_true
  end
  
  test "#published? returns true when published_at is a past date" do
    @content.published_at = 1.day.ago
    @content.published?.should be_true
  end
  
  test "#published? returns false when published_at is a future date" do
    @content.published_at = 1.day.from_now
    @content.published?.should be_false
  end
  
  test "#published? returns false when published_at is nil" do
    @content.published_at = nil
    @content.published?.should be_false
  end
  
  # just_published?
  
  test "just_published? is true when the content was published during the current request cycle" do
    @content.update_attributes :published_at => Time.now
    @content.just_published?.should be_true
  end
  
  test "just_published? is false when the content was published during a previous request cycle" do
    @content.update_attributes :published_at => Time.now
    @content.clear_changes!
    @content.just_published?.should be_false
  end
  
  test "just_published? is false when the content is not published" do
    @content.update_attributes :published_at => nil
    @content.clear_changes!
    @content.just_published?.should be_false
  end
  
  test "#attributes= calls update_categories if attributes include a :category_ids key" do
    mock(@content).update_categories.with([1, 2, 3])
    @content.attributes = { :category_ids => [1, 2, 3] }
  end
  
  # # FIXME actually diff something
  # #
  # # describe "#diff_against_version" do
  # #   before do
  # #     stub(HtmlDiff).diff
  # #     @other = Content.new :body_html => 'body', :excerpt_html => 'excerpt'
  # #     @content.body_html = 'body'
  # #     @content.excerpt_html = 'excerpt'
  # #     # stub(@content.versions).find_by_version(anything).returns @other
  # #   end
  # #
  # #   test "creates a diff" do
  # #     expectation do
  # #       mock(HtmlDiff).diff.with anything
  # #       @content.diff_against_version(1)
  # #     end
  # #   end
  # #
  # #   test "diffs excerpt_html + body_html" do
  # #     [@content, @other].each do |target| [:body_html, :excerpt_html].each do |method|
  # #       mock(target).stub!(method).returns method.to_s
  # #     end end
  # #     @content.diff_against_version(1)
  # #   end
  # # end
  # 
  # FIXME use constants for comment_age!
  test "#comments_expired_at returns a date 1 day after the published_at date if comments expire after 1 day" do
    @content.comment_age = 1
    @content.comments_expired_at.should == @content.published_at + 1.day
  end
  
  test "#comments_expired_at returns the published_at date if comments are not allowed (i.e. expire after 0 days)" do
    @content.comment_age = 0
    @content.comments_expired_at.should == @content.published_at
  end
  
  test "#comments_expired_at returns a date in far future if comments never expire" do
    @content.comment_age = -1
    @content.comments_expired_at.should > 9998.years.from_now
  end
  
  # set_site
  test "#set_site sets the site_id from the section" do
    @content.site_id = nil
    @content.send :set_site
    @content.site_id.should == @content.section.site_id
  end
  
  test '#update_categories removes associated categories that are not included in passed category_ids' do
    @foo = Category.create! :title => 'foo', :section => @page
    @bar = Category.create! :title => 'bar', :section => @page
  
    @content.send :update_categories, [@foo.id, @bar.id]
    @content.categories.should_not include(@category)
  end
  
  test '#update_categories assigns categories that are included in passed category_ids but not already associated' do
    @foo = Category.create! :title => 'foo', :section => @page
    @bar = Category.create! :title => 'bar', :section => @page
  
    @content.send :update_categories, [@foo.id, @bar.id]
    @content.categories.should include(@foo, @bar)
  end
  
  # PERMALINK CREATION
  
  test "it generates a permalink from the title on create if the given permalink is empty" do
    content = Content.create! @content_attributes
    content.permalink.should == 'a-new-content'
  end
  
  test "it does not change the permalink on create if the given permalink is not empty" do
    content = Content.create! @content_attributes.update(:permalink => 'something-else')
    content.permalink.should == 'something-else'
  end
  
  test "it regenerates the permalink from the title on update when the permalink is deleted" do
    old_permalink = @content.permalink
    @content.update_attributes! :permalink => ''
    @content.permalink.should == old_permalink
  end
  
  test "it does not regenerate the permalink on update if not updated with a new permalink" do
    old_permalink = @content.permalink
    @content.update_attributes! :body => 'just a new body'
    @content.permalink.should == old_permalink
  end
  
  test "it does not regenerate the permalink on update if the given permalink is not empty" do
    @content.update_attributes! :permalink => 'something-else'
    @content.permalink.should == 'something-else'
  end
  
  test "creates unique permalinks" do
    content = nil
    4.times { content = Content.create! @content_attributes.merge(:title => "unique") }
    content.permalink.should == 'unique-3'
  end
  
  test "it removes characters from the permalink" do
    title = "it's a test title, <em>okay</em>?"
    content = Content.create! @content_attributes.merge(:title => title)
    content.permalink.should == "its-a-test-title-okay"
  end
  
  test "transliterates characters for permalinks" do
    transliterations = {
      %w(À Á Â Ã Å)  => "A",
      %w(Ä Æ)        => "Ae",
      "Ç"            => "C",
      "Ð"            => "D",
      %w(È É Ê Ë)    => "E",
      %w(Ì Í Î Ï)    => "I",
      "Ñ"            => "N",
      %w(Ò Ó Ô Õ Ø)  => "O",
      "Ö"            => "Oe",
      %w(Ù Ú Û)      => "U",
      "Ü"            => "Ue",
      # "Ý"            => "Y", # StringEx transliteration is 'U'
      # "Þ"            => "p", # StringEx transliteration is 'th'
      %w(à á â ã å)  => "a",
      %w(ä æ)        => "ae",
      "ç"            => "c",
      "ð"            => "d",
      %w(è é ê ë)    => "e",
      %w(ì í î ï)    => "i",
      "ñ"            => "n",
      %w(ò ó ô õ ø)  => "o",
      "ö"            => "oe",
      "ß"            => "ss",
      %w(ù ú û)      => "u",
      "ü"            => "ue",
      "ý"            => "y"
    }
  
    source, expected = '', ''
    transliterations.each do |from, to|
      from = [from] unless from.is_a?(Array)
      source   << from.join
      expected << to * from.size
    end
  
    source.to_url.should == expected.downcase
  end
  
  # VERSIONING
  
  test "does not create a new version if neither title, excerpt nor body attributes have changed" do
    @content.save_version?.should be_false
  end
  
  test "creates a new version if the title attribute has changed" do
    @content.title = 'another title'
    @content.save_version?.should be_true
  end
  
  test "creates a new version if the excerpt attribute has changed" do
    @content.excerpt = 'another excerpt'
    @content.save_version?.should be_true
  end
  
  test "creates a new version if the body attribute has changed" do
    @content.body = 'another body'
    @content.save_version?.should be_true
  end
  
  # TAGGING
  
  test "works with quoted tags" do
    @content.tag_list = '"foo bar"'
    @content.save!
    @content.reload
    @content.tag_list.should == ['foo bar']
    @content.cached_tag_list.should == '"foo bar"'
  end
end