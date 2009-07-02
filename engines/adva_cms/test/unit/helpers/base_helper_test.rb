require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class BaseHelperTest < ActionView::TestCase
  include BaseHelper

  def setup
    super
    @site = Site.first
    stub(Time.zone).now.returns Time.local(2008, 1, 2)
    stub(Time.zone.now).yesterday.returns Time.local(2008, 1, 1)
  end

  # LINK HELPERS

  # method commented out, doesn't seem to be used anyway
  # TODO: should probably solved differently?
  # test "#link_to_section_main_action builds a link to Wikipages index if section is a Wiki" do
  #   @section = Wiki.first
  #   stub(self).admin_wikipages_path(@site, @section).returns('/path/to/wikipages')
  #   link_to_section_main_action(@site, @section)
  # end
  #
  # test "#link_to_section_main_action builds a link to Articles index if section is a Blog" do
  #   @section = Blog.first
  #   stub(self).admin_articles_path(@site, @section).returns('/path/to/articles')
  #   link_to_section_main_action(@site, @section)
  # end
  #
  # test "#link_to_section_main_action builds a link to Articles index if section is a Section" do
  #   @section = Section.first
  #   stub(self).admin_articles_path(@site, @section).returns('/path/to/articles')
  #   link_to_section_main_action(@site, @section)
  # end
  #
  # test "#link_to_section_main_action builds a link to Boards index if section is a Forum" do
  #   @section = Forum.first
  #   stub(self).admin_boards_path(@site, @section).returns('/path/to/boards')
  #   link_to_section_main_action(@site, @section)
  # end

  # SPLIT_FORM_FOR

  test '#split_form_for' do
    @head = '<form action="path/to/article" method="post">'
    @form = "the form\n</form>"
    stub(self).with_output_buffer.returns "#{@head}\n#{@form}"

    mock(self).content_for :form, @head # the form header tag is pushed to content_for :form
    mock(self).concat 'the form'        # the form body is concated to the current output buffer
    split_form_for :foo
  end

  # FIXME ... wtf again
  #
  # test '#split_form_for' do
  #   stub(self).protect_against_forgery?.returns false
  #   self.output_buffer = ''
  #   split_form_for(Article.first, {:url => 'path/to/article'}) { }
  #   self.output_buffer ... is still empty at this point
  # end

  # FILTER OPTIONS

  test '#filter_options returns a nested array containing the installed column filters' do
    filter_options.sort.should == [["Plain HTML", ""],
                                   ["Markdown", "markdown_filter"],
                                   ["Markdown with Smarty Pants", "smartypants_filter"],
                                   ["Textile", "textile_filter"]].sort
  end
end

class BaseHelperAuthorOptionsTest < ActiveSupport::TestCase
  include BaseHelper

  def setup
    super

    @user = User.new :name => 'John Doe'
    @member_1 = User.new :name => 'Donald Duck'
    @member_2 = User.new :name => 'Uncle Scrooge'

    @user.save(false)
    @member_1.save(false)
    @member_2.save(false)

    stub(self).current_user.returns @user
  end

  # AUTHOR OPTIONS

  test '#author_options returns a nested array containing the current user as a fallback option if the site does not have any members' do
    users = []
    author_options(users).should == [['John Doe', @user.id]]
  end

  test '#author_options returns a nested array containing the members of the site' do
    users = [@user]
    author_options(users).should == [['John Doe', @user.id]]
  end

  test '#author_options always returns current_user as an option along with the given users and makes sure user names are unique' do
    expected_options = [['John Doe', @user.id], ['Donald Duck', @member_1.id], ['Uncle Scrooge', @member_2.id]]
    author_options([@member_1, @member_2]).should == expected_options
    author_options([@user, @member_1, @member_2, @user]).should == expected_options
  end

  test "#author_selected returns an id of current_user if article does not have an author" do
    author_selected(nil).should == @user.id
  end
end

class BaseHelperMicroformatsTest < ActiveSupport::TestCase
  include ActionView::Helpers::TranslationHelper
  include BaseHelper

  def setup
    super
    Time.zone   = 'Vienna'
    @utc_time   = Time.utc        2008, 10, 9, 12, 0, 0
    @local_time = Time.zone.local 2008, 10, 9, 14, 0, 0
  end

  def teardown
    super
    Time.zone   = 'UTC'
  end
  
  # DATETIME MICROFORMAT HELPERS

  test "#datetime_with_microformat displays the passed object when passed a non-Date/Time object" do
    datetime_with_microformat(nil).should be_nil
    datetime_with_microformat(1).should == 1
    datetime_with_microformat('1').should == '1'
  end

  test "#datetime_with_microformat displays a UTC time" do
    datetime_with_microformat(@utc_time).should ==
      '<abbr class="datetime" title="2008-10-09T12:00:00Z">Thu, 09 Oct 2008 14:00:00 +0200</abbr>'
  end

  test "#datetime_with_microformat displays a non-UTC time and converts it to UTC" do
    datetime_with_microformat(@local_time).should ==
      '<abbr class="datetime" title="2008-10-09T12:00:00Z">Thu, 09 Oct 2008 14:00:00 +0200</abbr>'
  end

  test "#datetime_with_microformat displays a UTC time with a given date format" do
    datetime_with_microformat(@utc_time, :format => :long).should ==
      '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09, 2008 14:00</abbr>'
  end

  test "#datetime_with_microformat displays a non-UTC time with a given date format and converts it to UTC" do
    datetime_with_microformat(@local_time, :format => :long).should ==
      '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09, 2008 14:00</abbr>'
  end

  test "#datetime_with_microformat displays a UTC time with a given custom date format" do
    datetime_with_microformat(@utc_time, :format => '%Y/%m/%d').should ==
      '<abbr class="datetime" title="2008-10-09T12:00:00Z">2008/10/09</abbr>'
  end

  test "#datetime_with_microformat displays a non-UTC time with a given custom date format and converts it to UTC" do
    datetime_with_microformat(@local_time, :format => '%Y/%m/%d').should ==
      '<abbr class="datetime" title="2008-10-09T12:00:00Z">2008/10/09</abbr>'
  end
end
