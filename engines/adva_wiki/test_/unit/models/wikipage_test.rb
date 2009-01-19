require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class WikipageTest < ActiveSupport::TestCase
  def setup
    super
    @wiki = Wiki.first
    @wikipage = @wiki.wikipages.first
  end

  test 'sanitizes the body_html attribute' do
    # FIXME implement matcher
    # Wikipage.should filter_attributes(:sanitize => :body_html)
  end

  test 'does not sanitize the body and cached_tag_list attributes' do
    # FIXME implement matcher
    # Wikipage.should filter_attributes(:except => [:body, :cached_tag_list])
  end
  
  # CALLBACKS
  
  test 'sets its  attribute to the current time before create' do # TODO why does it do this??
    Wikipage.before_create.should include(:set_published)
  end

  test 'initializes the title from the permalink for new records that do not have a title' do
    wikipage = Wikipage.new :permalink => 'something-new'
    wikipage.title.should == 'Something new'
  end

  # accept_comments?
  test "accepts comments when the wiki does" do
    stub(@wikipage.section.target).accept_comments?.returns true
    @wikipage.accept_comments?.should be_true
  end

  test "does not accept comments when the wiki doesn't" do
    stub(@wikipage.section.target).accept_comments?.returns false
    @wikipage.accept_comments?.should be_false
  end

  # filtering
  test "it allows using insecure html in article body and excerpt" do
    @wikipage.body = 'p{position:absolute; top:50px; left:10px; width:150px; height:150px}. insecure css'
    @wikipage.filter = 'textile_filter'
    @wikipage.save(false)
    @wikipage.body_html.should == %(<p style="position:absolute; top:50px; left:10px; width:150px; height:150px;">insecure css</p>)
  end
end