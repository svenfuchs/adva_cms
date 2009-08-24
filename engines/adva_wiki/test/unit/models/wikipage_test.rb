require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class WikipageTest < ActiveSupport::TestCase
  def setup
    super
    @wiki = Wiki.first
    @wikipage = @wiki.wikipages.first
  end

  test 'sanitizes the body_html attribute' do
    Wikipage.should filter_attributes(:sanitize => :body_html)
  end

  test 'does not sanitize the body and cached_tag_list attributes' do
    Wikipage.should filter_attributes(:except => [:body, :cached_tag_list])
  end

  # validations

  # FIXME implement!
  # test "validates presence of an author (through belongs_to_author)" do
  #   @wikipage.should validate_presence_of(:author)
  # end
  #
  # test "validates that the author is valid (through belongs_to_author)" do
  #   @wikipage.author = User.new
  #   @wikipage.valid?.should be_false
  # end

  test "validates the uniqueness of the permalink per section" do
    @wikipage = Wikipage.new
    @wikipage.should validate_uniqueness_of(:permalink, :scope => :section_id)
  end

  # CALLBACKS
  test 'sets its published attribute to the current time before create' do # FIXME why does it do this??
    Wikipage.before_create.should include(:set_published)
  end

  test 'initializes the title from the permalink for new records that do not have a title' do
    wikipage = Wikipage.new(:permalink => 'something-new')
    wikipage.title.should == 'Something new'
  end

  # accept_comments?
  test "accepts comments when the wiki does" do
    stub(@wikipage.section.target).accept_comments?.returns(true)
    @wikipage.should accept_comments
  end

  test "does not accept comments when the wiki doesn't" do
    stub(@wikipage.section.target).accept_comments?.returns(false)
    @wikipage.should_not accept_comments
  end

  # filtering
  test "it does not allow using insecure html in wikipage body and excerpt" do
    # @wikipage = Wikipage.new :body => 'p{position:absolute; top:50px; left:10px; width:150px; height:150px}. secure html',
    #                          :site => Site.first, :section => @wiki, :author => stub_user
    @wikipage.body = 'p{position:absolute; top:50px; left:10px; width:150px; height:150px}. the paragraph'
    @wikipage.filter = 'textile_filter'
    assert @wikipage.save(false)
    @wikipage.body_html.should == %(<p>the paragraph</p>)
  end
end