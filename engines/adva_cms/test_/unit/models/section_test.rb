require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class SectionTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.first
    @section = @site.sections.first
  end
  
  test "acts as a role context for the moderator role" do
    # FIXME implement matcher
    # Section.should act_as_role_context(:roles => :moderator)
  end

  test "serializes its actual permissions" do
    Section.serialized_attributes.keys.should include('permissions')
  end

  test "has an option :articles_per_page" do
    lambda{ @section.articles_per_page }.should_not raise_error
  end

  test "serialize the option :articles_per_page to the database" do
    @section.instance_variable_set :@options, nil
    @section.save; @section.reload
    @section.articles_per_page.should == Section.option_definitions[:articles_per_page][:default]
    
    @section.articles_per_page = 20
    @section.save; @section.reload
    @section.articles_per_page.should == 20
  end

  test "has a permalink generated from the title" do
    @section.title = 'new section title'
    @section.permalink = nil
    @section.send :create_unique_permalink
    @section.permalink.should == 'new-section-title'
  end

  test "acts as a nested set" do
    # FIXME implement matcher
    # Section.should act_as_nested_set
  end

  test "acts as a commentable" do
    # FIXME implement matcher
    # Section.should act_as_commentable
  end

  test "instantiates with single table inheritance" do
    # FIXME implement matcher
    # Section.should instantiate_with_sti
  end

  test "has a comments counter" do
    # FIXME implement matcher
    # Section.should have_counter(:comments)
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

  # articles association
  
  test "articles#primary returns the topmost published article" do
    mock(Article).find_published(:first, {:order => :position}).returns :article
    @section.articles.primary.should == :article
  end

  test "articles#permalinks returns the permalinks of all published articles" do
    articles = [Article.new(:permalink => 'article-1'), Article.new(:permalink => 'article-2')]
    articles.each { |article| mock.proxy(article).permalink }
    stub(Article).find_published(:all).returns articles
    @section.articles.permalinks.should == ['article-1', 'article-2']
  end

  # categories association
  
  test "categories#roots returns all categories that do not have a parent category" do
    mock(@section.categories).find(:all, hash_including(:conditions => {:parent_id => nil}))
    @section.categories.roots
  end
  
  # callbacks
  
  test "sets the path before validation" do
    Section.before_validation.should include(:set_path)
  end

  test "sets the comment age before validation" do
    Section.before_validation.should include(:set_comment_age)
  end

  test "generates the permalink before validation" do
    Section.before_validation.should include(:create_unique_permalink)
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
  
  test "Section.content_type returns 'Article'" do
    Section.content_type.should == 'Article'
  end
  
  test "Section.types returns a collection of registered Section types" do
    Section.types.should include('Section')
  end

  test "Section.register_type adds a Section type to the type collection" do
    Section.register_type('Galerie')
    Section.types.should include('Galerie')
  end
  
  test "Section.register_type should not shift 'Section' from the top position" do
    Section.register_type('123-section')
    Section.types.first.should == 'Section'
  end
  
  # PUBLIC INSTANCE METHODS
  
  test "#type returns 'Section' for a Section" do
    s = Section.create! :title => 'title', :site => @site
    s.type.should == 'Section'
  end

  test "#owner returns the site" do
    @section.owner.should == @site
  end

  test "#tag_counts returns the tag_counts for this site's content's tags" do
    mock(Content).tag_counts :conditions => "section_id = #{@section.id}"
    @section.tag_counts
  end

  # FIXME
  # test "#render_options should be specified but looks pretty uncomprehensible right now"

  test "#root_section? returns true if this section is the site's root section" do
    @site.sections.root.root_section?.should == true
    Section.new(:site => @site).root_section?.should == false
  end

  test "#accept_comments? is true when comments are not 'not-allowed' (-1) (see comment_expiration_options)" do
    @section.comment_age = 0
    @section.accept_comments?.should == true
  end

  test "#accept_comments? is false when comments are 'not-allowed' (-1) (see comment_expiration_options)" do
    @section.comment_age = -1
    @section.accept_comments?.should == false
  end

  # PROTECTED INSTANCE METHODS
  
  test "#set_comment_age sets the comment_age to -1 if it's not already set" do
    @section.comment_age = nil
    @section.send :set_comment_age
    @section.comment_age.should_not == nil
  end

  test "#set_comment_age does not change an already set comment_age" do
    @section.comment_age = 99
    @section.send :set_comment_age
    @section.comment_age.should == 99
  end

  test "#set_path rebuilds the section's path" do
    mock(@section).build_path.returns 'the-new-path'
    @section.send :set_path
    @section.path.should == 'the-new-path'
  end

  test "#build_path builds a path by joining self and anchestor permalinks with '/'" do
    section = bunch_of_nested_sections!
    section.send(:build_path).should == "home/about/location"
  end
  
  def bunch_of_nested_sections!
    home = Section.create!     :site => @site,
                               :title => 'homepage',
                               :permalink => 'home'
    about = Section.create!    :site => @site,
                               :title => 'about us',
                               :permalink => 'about'
    location = Section.create! :site => @site,
                               :title => 'how to find us',
                               :permalink => 'location'
    
    about.move_to_child_of(home)
    location.move_to_child_of(about)
    location
  end
end
