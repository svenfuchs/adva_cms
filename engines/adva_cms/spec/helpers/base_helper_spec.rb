require File.dirname(__FILE__) + '/../spec_helper'

describe BaseHelper do
  # TODO: should maybe solved differently? since we're testing for implementation here, it might be worth some
  #   investigation ...
  describe "#link_to_section_main_action" do
    before(:each) do
      @site = stub_model(Site)
      @site.stub!(:to_param).and_return(1)
    end

    it "builds a link to Wikipages index if section is a Wiki" do
      @section = stub_model(Wiki)
      helper.should_receive(:admin_wikipages_path).with(@site, @section).and_return('/path/to/wikipages')
      helper.link_to_section_main_action(@site, @section)
    end

    it "builds a link to Articles index if section is a Blog" do
      @section = stub_model(Blog)
      helper.should_receive(:admin_articles_path).with(@site, @section).and_return('/path/to/articles')
      helper.link_to_section_main_action(@site, @section)
    end

    it "builds a link to Articles index if section is a Section" do
      @section = stub_model(Section)
      helper.should_receive(:admin_articles_path).with(@site, @section).and_return('/path/to/articles')
      helper.link_to_section_main_action(@site, @section)
    end

    it "builds a link to Boards index if section is a Forum" do
      @section = stub_model(Forum)
      helper.should_receive(:admin_boards_path).with(@site, @section).and_return('/path/to/boards')
      helper.link_to_section_main_action(@site, @section)
    end
  end

  describe '#split_form_for' do
    before :each do
      @args = 'name', stub_model(Article), {:url => 'path/to/article'}
      @head = '<form action="path/to/article" method="post">'
      @form = "the form\n</form>"

      # maybe rework this spec as it tests too much for implementation ...?
      helper.stub!(:with_output_buffer).and_return "#{@head}\n#{@form}"
      helper.stub! :content_for
      helper.stub! :concat
    end

    it 'splits off the form head tag from the generated form' do
      _erbout = ''
      helper.should_receive(:concat).with 'the form'
      helper.split_form_for *@args do 'the form' end
    end

    it 'captures form head tag to content_for :form' do
      _erbout = ''
      helper.should_receive(:content_for).with(:form, @head)
      helper.split_form_for *@args do 'the form' end
    end
  end

  describe 'date helpers' do
    before :each do
      Time.zone.stub!(:now).and_return Time.local(2008, 1, 2)
      Time.zone.now.stub!(:yesterday).and_return Time.local(2008, 1, 1)
    end

    it '#todays_short_date returns a short formatted version of Time.zone.now' do
      helper.todays_short_date.should == 'January 2nd'
    end

    it '#yesterdays_short_date returns a short formatted version of Time.zone.now.yesterday' do
      helper.yesterdays_short_date.should == 'January 1st'
    end
  end

  it '#filter_options returns a nested array containing the installed column filters' do
    helper.filter_options.sort.should == [["Plain HTML", ""],
                                          ["Markdown", "markdown_filter"],
                                          ["Markdown with Smarty Pants", "smartypants_filter"],
                                          ["Textile", "textile_filter"]].sort
  end

  describe 'author selection' do
    before(:each) do
      @site = mock 'Site'
      helper.instance_variable_set(:@site, @site) # wtf
      
      @user     = mock_model User, :id => 1, :name => 'John Doe'
      @member_1 = mock_model User, :id => 2, :name => 'Donald Duck'
      @member_2 = mock_model User, :id => 3, :name => 'Uncle Scrooge'
      helper.stub!(:current_user).and_return(@user)
    end

    it '#author_options returns a nested array containing the current user as a fallback option if the site does not have any members' do
      @site.stub!(:users).and_return []
      helper.author_options.should == [['John Doe', 1]]
    end

    it '#author_options returns a nested array containing the members of the site' do
      @site.stub!(:users).and_return [@user]
      helper.author_options.should == [['John Doe', 1]]
    end
    
    it '#author_options returns always current_user as an option along with the members of the site' do
      @site.stub!(:users).and_return [@member_1, @member_2]
      helper.author_options.should == [['Donald Duck', 2], ['John Doe', 1], ['Uncle Scrooge', 3]]
    end
    
    it '#author_options returns always current_user as an option along with the members of the site and make sure user names are unique' do
      @site.should_receive(:users).exactly(2).times.and_return [@member_1, @member_2, @user]
      helper.author_options.should == [['Donald Duck', 2], ['John Doe', 1], ['Uncle Scrooge', 3]]
    end

    it "#author_preselect returns an id of current_user if article does not have any author or if content cannot be determined" do
      helper.stub!(:current_user).and_return(@member_1)
      helper.author_preselect.should == 2
    end
  end

  describe "#datetime_with_microformat" do
    before :each do
      @utc_time = Time.utc(2008, 10, 9, 12, 0, 0)
      Time.zone = 'Vienna'
      @local_time = Time.local(2008, 10, 9, 14, 0, 0)
    end

    it "displays the passed object when passed a non-Date/Time object" do
      helper.datetime_with_microformat(nil).should be_nil
      helper.datetime_with_microformat(1).should == 1
      helper.datetime_with_microformat('1').should == '1'
    end

    it "displays a UTC time" do
      @utc_time.stub!(:to_s).with(:standard).and_return("October 09, 2008 @ 12:00 PM")
        @utc_time.stub!(:utc).and_return(@utc_time)

      helper.datetime_with_microformat(@utc_time).should == '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09, 2008 @ 12:00 PM</abbr>'
    end

    it "displays a non-UTC time and converts it to UTC" do
      @local_time.stub!(:to_s).with(:standard).and_return("October 09, 2008 @ 2:00 PM")
      @local_time.should_receive(:utc).and_return(@utc_time)

      helper.datetime_with_microformat(@local_time).should == '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09, 2008 @ 2:00 PM</abbr>'
    end

    it "displays a UTC time with a given date format" do
      @utc_time.stub!(:to_s).with(:plain).and_return("October 09 12:00 PM")
        @utc_time.stub!(:utc).and_return(@utc_time)

      helper.datetime_with_microformat(@utc_time, :format => :plain).should == '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09 12:00 PM</abbr>'
    end

    it "displays a non-UTC time with a given date format and converts it to UTC" do
      @local_time.stub!(:to_s).with(:plain).and_return("October 09 12:00 PM")
      @local_time.should_receive(:utc).and_return(@utc_time)

      helper.datetime_with_microformat(@local_time, :format => :plain).should == '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09 12:00 PM</abbr>'
    end

    it "displays a UTC time with a given custom date format" do
      @utc_time.stub!(:strftime).with('%Y/%m/%d').and_return("2008/10/09")
      @utc_time.stub!(:utc).and_return(@utc_time)
      #@utc_time.stub!(:to_s).with('%Y/%m/%d').and_return("2008/10/09") # with localized_dates plugin

      helper.datetime_with_microformat(@utc_time, :format => '%Y/%m/%d').should == '<abbr class="datetime" title="2008-10-09T12:00:00Z">2008/10/09</abbr>'
    end

    it "displays a non-UTC time with a given custom date format and converts it to UTC" do
      @local_time.stub!(:strftime).with('%Y/%m/%d').and_return("2008/10/09")
      @local_time.should_receive(:utc).and_return(@utc_time)
      #@local_time.stub!(:to_s).with('%Y/%m/%d').and_return("2008/10/09") # with localized_dates plugin

      helper.datetime_with_microformat(@local_time, :format => '%Y/%m/%d').should == '<abbr class="datetime" title="2008-10-09T12:00:00Z">2008/10/09</abbr>'
    end
  end
end
