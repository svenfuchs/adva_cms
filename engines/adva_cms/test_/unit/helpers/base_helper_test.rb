require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class BaseHelperTest < ActiveSupport::TestCase
  include BaseHelper
  
  include ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::RecordIdentificationHelper
  include ActionView::Helpers::TextHelper

  attr_accessor :output_buffer
  
  def setup
    super
    @site = Site.first
    stub(Time.zone).now.returns Time.local(2008, 1, 2)
    stub(Time.zone.now).yesterday.returns Time.local(2008, 1, 1)
  end
  
  # LINK HELPERS

  # TODO: should probably solved differently? 
  test "#link_to_section_main_action builds a link to Wikipages index if section is a Wiki" do
    @section = Wiki.first
    stub(self).admin_wikipages_path(@site, @section).returns('/path/to/wikipages')
    link_to_section_main_action(@site, @section)
  end

  test "#link_to_section_main_action builds a link to Articles index if section is a Blog" do
    @section = Blog.first
    stub(self).admin_articles_path(@site, @section).returns('/path/to/articles')
    link_to_section_main_action(@site, @section)
  end

  test "#link_to_section_main_action builds a link to Articles index if section is a Section" do
    @section = Section.first
    stub(self).admin_articles_path(@site, @section).returns('/path/to/articles')
    link_to_section_main_action(@site, @section)
  end

  test "#link_to_section_main_action builds a link to Boards index if section is a Forum" do
    @section = Forum.first
    stub(self).admin_boards_path(@site, @section).returns('/path/to/boards')
    link_to_section_main_action(@site, @section)
  end
  
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
  
  # DATE HELPERS
  
  test '#todays_short_date returns a short formatted version of Time.zone.now' do
    todays_short_date.should == 'January 2nd'
  end

  test '#yesterdays_short_date returns a short formatted version of Time.zone.now.yesterday' do
    yesterdays_short_date.should == 'January 1st'
  end
  
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
  # include ActionView::Helpers::TranslationHelper, ActionView::Helpers::TagHelper, ActionView::Helpers::UrlHelper
  
  def setup
    @site = Site.new
    instance_variable_set(:@site, @site) # wtf
    
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
    stub(@site).users.returns []
    author_options.should == [['John Doe', @user.id]]
  end

  test '#author_options returns a nested array containing the members of the site' do
    stub(@site).users.returns [@user]
    author_options.should == [['John Doe', @user.id]]
  end
  
  test '#author_options returns always current_user as an option along with the members of the site' do
    stub(@site).users.returns [@member_1, @member_2]
    author_options.should == [['Donald Duck', @member_1.id], ['John Doe', @user.id], ['Uncle Scrooge', @member_2.id]]
  end
  
  test '#author_options returns always current_user as an option along with the members of the site and makes sure user names are unique' do
    stub(@site).users.returns [@user, @member_1, @member_2, @user]
    author_options.should == [['Donald Duck', @member_1.id], ['John Doe', @user.id], ['Uncle Scrooge', @member_2.id]]
  end
  
  test "#author_preselect returns an id of current_user if article does not have any author or if content cannot be determined" do
    stub(self).current_user.returns @member_1
    author_preselect.should == @member_1.id
  end
end

class BaseHelperMicroformatsTest < ActiveSupport::TestCase
  include BaseHelper
  
  def setup
    @utc_time = Time.utc(2008, 10, 9, 12, 0, 0)
    Time.zone = 'Vienna'
    @local_time = Time.local(2008, 10, 9, 14, 0, 0)
  end
  
  # DATETIME MICROFORMAT HELPERS

  test "#datetime_with_microformat displays the passed object when passed a non-Date/Time object" do
    datetime_with_microformat(nil).should == nil
    datetime_with_microformat(1).should == 1
    datetime_with_microformat('1').should == '1'
  end

  test "#datetime_with_microformat displays a UTC time" do
    datetime_with_microformat(@utc_time).should ==
      '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09, 2008 @ 12:00 PM</abbr>'
  end

  test "#datetime_with_microformat displays a non-UTC time and converts it to UTC" do
    datetime_with_microformat(@local_time).should ==
      '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09, 2008 @ 02:00 PM</abbr>'
  end
  
  test "#datetime_with_microformat displays a UTC time with a given date format" do
    datetime_with_microformat(@utc_time, :format => :plain).should ==
      '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09 12:00 PM</abbr>'
  end
  
  test "#datetime_with_microformat displays a non-UTC time with a given date format and converts it to UTC" do
    datetime_with_microformat(@local_time, :format => :plain).should ==
      '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09 02:00 PM</abbr>'
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
