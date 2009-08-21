require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

require 'action_view/test_case'

class WikiHelperTest < ActionView::TestCase
  attr_accessor :output_buffer

  include WikiHelper
  include RolesHelper

  attr_reader :controller
  delegate :wikipage_path_with_home, :to => :controller # umpf

  def setup
    super
    @section = Wiki.first
    @wikipage = @section.wikipages.first
    @another_wikipage = @section.wikipages.second

    @controller = TestController.new
    @output_buffer = ''

    stub(self).protect_against_forgery?.returns false
  end

  # wikipage_path
  test "#wikipage_path alias_chains the existing wikipage_path" do
    @controller.should respond_to(:wikipage_path_with_home)
  end
  
  test "#wikipage_path removes the path segments /wikipages/home from the result of wikipage_path_home" do
    path = @controller.send(:wikipage_path, @section, @wikipage)
    path.should == '/'
  end
  
  test "#wikipage_path returns the unmodified result of wikipage_path_home when it does not contain /wikipages/home)" do
    path = @controller.send(:wikipage_path, @section, @another_wikipage)
    path.should =~ %r(/wikipages/another-wikipage)
  end
  
  # wikipage_url
  test "#wikipage_url alias_chains the existing wikipage_url" do
    @controller.should respond_to(:wikipage_url_with_home)
  end
  
  test "#wikipage_url removes the path segments /wikipages/home from the result of wikipage_url_home" do
    url = @controller.send(:wikipage_url, @section, @wikipage)
    url.should == 'http://test.host'
  end
  
  test "#wikipage_url returns the unmodified result of wikipage_url_home when it does not contain /wikipages/home)" do
    url = @controller.send(:wikipage_url, @section, @another_wikipage)
    url.should =~ %r(/wikipages/another-wikipage)
  end
  
  # wikify
  test "#wikify detextilizes the given string using Redcloth" do
    wikify('**bold**').should == '<p><b>bold</b></p>'
  end
  
  test "#wikify calls wikify_link for everything included in [[double backets]]" do
    mock(self).wikify_link('link', nil).times(2)
    wikify('[[link]] [[link]]')

    mock(self).wikify_link('link', 'text').times(2)
    wikify('[[link|text]] [[link|text]]')
  end

  test "#wikify builds links (with and without extra text)" do
    path = wikipage_path(@section, 'a-missing-wikipage')
    wikify('[[a missing wikipage]]').should include(%(<a href="#{path}" class="new_wiki_link">a missing wikipage</a>))
    wikify('[[a missing wikipage|this is missing]]').should include(%(<a href="#{path}" class="new_wiki_link">this is missing</a>))
    wikify('[[a missing wikipage|we can use | goalposts]]').should include(%(<a href="#{path}" class="new_wiki_link">we can use | goalposts</a>))
  end
  
  test "#wikify auto_links the result" do
    wikify('http://google.com').should =~ %r(<a href="http://google.com">http://google.com</a>)
  end
  
  # wikify_link
  test "#wikify_link escapes the given string to a permalink" do
    str = 'a wikipage'
    mock(str).to_url.returns 'a-wikipage'
    wikify_link(str)
  end
  
  test "#wikify_link with no wikipage exists for the given permalink it adds a css class 'new_wiki_link'" do
    path = wikipage_path(@section, 'a-missing-wikipage')
    result = wikify_link('a missing wikipage')
    result.should == %(<a href="#{path}" class="new_wiki_link">a missing wikipage</a>)
  end
  
  test "#wikify_link with a wikipage exists for the given permalink it returns a link" do
    result = wikify_link(@wikipage.permalink)
    result.should == %(<a href="/">home</a>)
  end
  
  # wiki_edit_links
  test "#wiki_edit_links with a home wikipage that is the current/last version" do
    links = wiki_edit_links(@wikipage)
  
    links.should     =~ /edit this page/             # contains a link to edit the wikipage
    links.should_not =~ /rollback to this revision/  # does not contain a link to rollback to this revision
    links.should     =~ /view previous revision/     # contains a link to view the previous revision
    links.should_not =~ /view next revision/         # contains a link to view the next revision
    links.should_not =~ /return to current revision/ # does not contain a link to return to the current revision
    links.should_not =~ /return to home/             # does not contain a link to the wiki home page
  end
  
  test "#wiki_edit_links with a non-home wikipage that is the current/last version" do
    links = wiki_edit_links(@another_wikipage)
  
    links.should     =~ /edit this page/             # contains a link to edit the wikipage
    links.should_not =~ /rollback to this revision/  # does not contain a link to rollback to this revision
    links.should     =~ /view previous revision/     # contains a link to view the previous revision
    links.should_not =~ /view next revision/         # does not contain a link to view the next revision
    links.should_not =~ /return to current revision/ # does not contain a link to return to the current revision
    links.should     =~ /return to home/             # contains a link to the wiki home page
  end
  
  test "#wiki_edit_links with a home wikipage that is the first version" do
    @wikipage.revert_to(@wikipage.versions.first)
    links = wiki_edit_links(@wikipage)
  
    links.should_not =~ /edit this page/             # does not contain a link to edit the wikipage
    links.should     =~ /rollback to this revision/  # contains a link to rollback to this revision
    links.should_not =~ /view previous revision/     # does not contain a link to view the previous revision
    links.should_not =~ /view next revision/         # contains a link to view the next revision
    links.should     =~ /return to current revision/ # contains a link to return to the current revision
    links.should_not =~ /return to home/             # does not contain a link to the wiki home page
  end
  
  test "#wiki_edit_links with a non-home wikipage that is an intermediate version" do
    @another_wikipage.revert_to(@another_wikipage.versions.second)
    links = wiki_edit_links(@another_wikipage)
  
    links.should_not =~ /edit this page/             # does not contain a link to edit the wikipage
    links.should     =~ /rollback to this revision/  # contains a link to rollback to this revision
    links.should     =~ /view previous revision/     # contains a link to view the previous revision
    links.should     =~ /view next revision/         # contains a link to view the next revision
    links.should     =~ /return to current revision/ # contains a link to return to the current revision
    links.should     =~ /return to home/             # contains a link to the wiki home page
  end
  
  test "#wiki_edit_links pointing to authorizing actions are enclosed in a tag with the visible_for class" do
    wiki_edit_links(@wikipage).should have_tag('.visible_for') do |tag|
      tag.should have_tag('a[href=?]', /edit/)
    end
    @wikipage.revert_to(@wikipage.versions.first)
    wiki_edit_links(@wikipage).should have_tag('.visible_for') do |tag|
      tag.should have_tag('a[href=?]', /version=/)
    end
  end
  
  # wikipages_title
  test "#wikipages_title" do
    category = @wikipage.categories.first
    tags = ['foo', 'bar']
  
    # returns the title with category if given
    wikipages_title(category).should == "Pages about a category"
  
    # returns the title with tags if given
    wikipages_title(nil, tags).should == "Pages tagged foo and bar"
  
    # returns the full collection title if all values are given
    wikipages_title(category, tags).should == "Pages about a category, tagged foo and bar"
  
    # returns the title wrapped into the format string if given
    wikipages_title(category, :format => '<h1>%s</h1>').should == "<h1>Pages about a category</h1>"
  
    # returns the default title if no parameters are given
    wikipages_title.should == "All pages"
  end
end
