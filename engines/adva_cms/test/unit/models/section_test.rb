require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class SectionTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.first
    @section = @site.sections.first
    @new_section = Section.new(:site => @site, :title => 'a test section', :parent_id => @section.id)
    @unpublished_section = Section.find_by_title('an unpublished section')
  end

  test "acts as a role context for the moderator role" do
    Section.should act_as_role_context(:roles => :moderator)
  end

  test "serializes its actual permissions" do
    Section.serialized_attributes.keys.should include('permissions')
  end

  test "has an option :contents_per_page" do
    lambda{ @section.contents_per_page }.should_not raise_error
  end

  test "serialize the option :contents_per_page to the database" do
    @section.instance_variable_set(:@options, nil)
    @section.save; @section.reload
    @section.contents_per_page.should == Section.option_definitions[:contents_per_page][:default]

    @section.contents_per_page = 20
    @section.save; @section.reload
    @section.contents_per_page.should == 20
  end

  test "has a permalink generated from the title" do
    Category.should have_permalink(:title)

    @section.title = 'new section title'
    @section.permalink = nil
    @section.send(:ensure_unique_url)
    @section.permalink.should == 'new-section-title'
  end

  test "acts as a nested set" do
    Section.should act_as_nested_set
  end

  test "has many comments" do
    Section.should have_many_comments
  end

  test "instantiates with single table inheritance" do
    Section.should instantiate_with_sti
  end

  test "has a comments counter" do
    Section.should have_counter(:comments)
  end

  test "belongs to a site" do
    @section.should belong_to(:site)
  end

  test "has many articles" do
    @section.should have_many(:articles)
  end

  test "has many categories" do
    @section.should have_many(:categories)
  end

  # categories association

  test "categories#roots returns all categories that do not have a parent category" do
    mock(@section.categories).find(:all, hash_including(:conditions => { :parent_id => nil }))
    @section.categories.roots
  end

  # callbacks

  test "sets the comment age before validation" do
    Section.before_validation.should include(:set_comment_age)
  end

  test "updates the path before save" do
    Section.before_save.should include(:update_path)
  end

  # validations

  # FIXME ... seems to break with install_controller#index
  # test "validates the presence of a site" do
  #  @section.should validate_presence_of(:site)
  # end

  test "validates the presence of a title" do
    @section.should validate_presence_of(:title)
  end

  test "validates the uniqueness of the permalink per site" do
    @section.should validate_uniqueness_of(:permalink, :scope => :site_id)
  end

  # CLASS METHODS

  test "Section.types returns a collection of registered Section types" do
    Section.types.should include('Page')
  end

  test "Section.register_type adds a Section type to the type collection" do
    Section.register_type('Galerie')
    Section.types.should include('Galerie')
  end

  test "Section.register_type should not shift 'Page' from the top position" do
    Section.register_type('123-foo-bar')
    Section.types.first.should == 'Page'
  end

  # PUBLIC INSTANCE METHODS

  test "#type returns 'Page' for a Page" do
    s = Page.create!(:title => 'title', :site => @site)
    s.type.should == 'Page'
  end

  test "#owner returns the site" do
    @section.owner.should == @site
  end

  test "#tag_counts returns the tag_counts for this site's content's tags" do
    mock(Content).tag_counts(:conditions => "section_id = #{@section.id}")
    @section.tag_counts
  end

  # FIXME
  # test "#render_options should be specified but looks pretty uncomprehensible right now"

  test "#root_section? returns true if this section is the site's root section" do
    @site.sections.root.should be_root_section
    Section.new(:site => @site).should_not be_root_section
  end

  test "#accept_comments? is true when comments are not 'not-allowed' (-1) (see comment_expiration_options)" do
    @section.comment_age = 0
    @section.should accept_comments
  end

  test "#accept_comments? is false when comments are 'not-allowed' (-1) (see comment_expiration_options)" do
    @section.comment_age = -1
    @section.should_not accept_comments
  end

  test "#state returns :pending if section isn't published" do
    page = Page.new(:site => @site, :single_article_mode => false)
    page.save(false)
    page.update_attribute(:published_at, nil)
    
    page.move_to_child_of(@section)

    page.state.should == :pending

    page.published_at = 2.days.from_now
    page.state.should == :pending
  end

  test "#state returns :published if section is published" do
    page = Page.new(:site => @site, :single_article_mode => false)
    page.save(false)
    page.move_to_child_of(@section)

    page.published_at = 2.days.ago
    page.state.should == :published
  end

  test "#published? is always true for root section" do
    @section.published_at = nil
    @section.should be_published
  end

  test "#published? is true when published_at is set to a date in the past" do
    page = Page.new(:site => @site, :single_article_mode => false)
    page.save(false)
    page.move_to_child_of(@section)

    page.published_at = 2.days.ago
    page.should be_published
  end

  test "#published? is false when published_at is not set or set to a date in the future" do
    page = Page.new(:site => @site, :single_article_mode => false)
    page.save(false)
    page.move_to_child_of(@section)

    page.published_at = nil
    page.should_not be_published

    page.published_at = 2.days.from_now
    page.should_not be_published
  end

  # TODO - check if necessary - could (or should) be implemented on controller level
  test "#published? is true if all ancestors are published too" do
    # TODO: nested set bug?
    # section = Page.new(:site => @site, :parent => parent_section, :published_at => 2.days.ago, :single_article_mode => false)
    section = Page.new(:title => 'test section', :site => @site, :published_at => 2.days.ago, :single_article_mode => false)
    section.save(false)
    section.move_to_child_of(@section)
    
    section.published?(true).should be_true
  end

  test "#published? is false if any ancestor is not published" do
    # TODO: nested set bug?
    # section = Page.new(:site => @site, :parent => parent_section, :published_at => 2.days.ago, :single_article_mode => false)
    section = Page.new(:site => @site, :published_at => 2.days.ago, :single_article_mode => false)
    section.save(false)
    section.move_to_child_of(@unpublished_section)

    section.published?(true).should be_false
  end

  test "#published= sets published_at to current time if set to 1 and published_at is blank" do
    stub(Time).now { Time.local(2009, 5, 20, 12, 0, 0) }
    section = Page.new(:single_article_mode => false)
    section.published_at = nil

    section.published = '1'
    section.published_at.should == Time.local(2009, 5, 20, 12, 0, 0)
  end

  test "#published= sets published_at to nil if set to 0" do
    section = Page.new(:single_article_mode => false)
    section.published_at = 2.days.ago

    section.published = '0'
    section.published_at.should be_nil
  end

  # PROTECTED INSTANCE METHODS

  test "#set_comment_age sets the comment_age to -1 if it's not already set" do
    @section.comment_age = nil
    @section.send(:set_comment_age)
    @section.comment_age.should_not be_nil
  end

  test "#set_comment_age does not change an already set comment_age" do
    @section.comment_age = 99
    @section.send(:set_comment_age)
    @section.comment_age.should == 99
  end

  test "#update_path rebuilds the section's path when the permalink has changed" do
    # grrr ... can't stub dynamic methods with RR
    # stub(@section).permalink_changed?.returns(true)
    stub(@section).attribute_changed?('permalink').returns(true)
    mock(@section).build_path.returns('the-new-path')
    @section.send(:update_path)
    @section.path.should == 'the-new-path'
  end

  test "#build_path builds a path by joining self and anchestor permalinks with '/'" do
    section = bunch_of_nested_sections!
    section.send(:build_path).should == "home/about/location"
  end

  test "#update_paths moves a new section to a child of its parent and updates the section paths" do
    @new_section.save
    assert_equal @section, @new_section.parent
  end
  
  test "publish sections by default" do
    @new_section.save
    assert_equal true, @new_section.published
  end
  
  test "publish sections by default, but respect user set published_at time" do
    time = Time.local(2009, 5, 20, 12, 0, 0)
    @new_section.published_at = time
    @new_section.save
    assert_equal time, @new_section.published_at
  end

  test "#update_paths should not lose the title of the section while moving the section - a bug fix" do
    unnested_section = Section.new(:site => @site, :title => 'unnested section')
    assert_equal 'unnested section', unnested_section.title
    assert unnested_section.save
    assert_equal 'unnested section', unnested_section.title
    assert_equal 'a test section', @new_section.title
    assert @new_section.save
    assert_equal 'a test section', @new_section.title
  end

  # NESTED SET

  test "initializes the lft and rgt attributes" do
    home, about, location = *bunch_of_sections!
    expected = [about.lft - 2, about.rgt - 2, location.lft - 2, location.rgt - 2]
    [home.lft, home.rgt, about.lft, about.rgt].should == expected
  end

  def bunch_of_sections!
    home     = @site.sections.create!(:title => 'homepage', :permalink => 'home')
    about    = @site.sections.create!(:title => 'about us', :permalink => 'about')
    location = @site.sections.create!(:title => 'how to find us', :permalink => 'location')
    [home, about, location]
  end

  def bunch_of_nested_sections!
    home, about, location = *bunch_of_sections!
    about.move_to_child_of(home)
    location.move_to_child_of(about)
    location
  end
end
