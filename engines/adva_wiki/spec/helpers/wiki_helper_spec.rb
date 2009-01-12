require File.dirname(__FILE__) + '/../spec_helper'

describe WikiHelper do
  include Stubby, WikiHelper, UsersHelper, RolesHelper

  before :each do
    stub_scenario :wiki_with_wikipages

    @user_role = Rbac::Role.build :user, :context => Wikipage.new(:author => User.new)
    @wikipage.stub!(:role_authorizing).and_return @user_role
    @wikipage.versions.first.stub!(:role_authorizing).and_return @user_role
    @wikipage.versions.last.stub!(:role_authorizing).and_return @user_role
  end

  def controller
    @controller
  end

  describe '#wikipage_path' do
    it "alias_chains the existing wikipage_path" do
      @controller.should respond_to(:wikipage_path_with_home)
    end
  
    it "delegates to the existing wikipage_path" do
      @controller.should_receive(:wikipage_path_with_home).and_return ''
      @controller.wikipage_path
    end
  
    it "removes the path segments /pages/home" do
      @controller.stub!(:wikipage_path_with_home).and_return '/wiki/pages/home'
      @controller.wikipage_path.should == '/wiki'
    end
  end
  
  describe '#wikipage_url' do
    it "alias_chains the existing wikipage_url" do
      @controller.should respond_to(:wikipage_url_with_home)
    end
  
    it "delegates to the existing wikipage_url" do
      @controller.should_receive(:wikipage_url_with_home).and_return ''
      @controller.wikipage_url
    end
  
    it "removes the path segments /pages/home" do
      @controller.stub!(:wikipage_url_with_home).and_return 'http://test.host/wiki/pages/home'
      @controller.wikipage_url.should == 'http://test.host/wiki'
    end
  end
  
  describe '#wikify' do
    it "detextilizes the given string using Redcloth" do
      helper.wikify('**bold**').should == '<p><b>bold</b></p>'
    end
  
    it "calls wikify_link for everything included in [[double backets]]" do
      helper.should_receive(:wikify_link).twice.with('link')
      helper.wikify('[[link]] [[link]]')
    end
  
    it "auto_links the result" do
      helper.wikify('http://google.com').should have_tag('a[href=?]', 'http://google.com')
    end
  end
  
  describe '#wikify_link' do
    before :each do
      PermalinkFu.stub!(:escape).and_return 'a-wikipage'
      Wikipage.stub!(:find_by_permalink)
      helper.stub!(:wikipage_path).and_return 'path/to/a-wikipage'
    end
  
    it "escapes the given string to a permalink" do
      PermalinkFu.should_receive(:escape).and_return 'a-wikipage'
      helper.wikify_link('a wikipage')
    end
  
    it "given a wikipage does not exist for that permalink it adds a css class 'new_wiki_link'" do
      helper.should_receive(:link_to).with 'a wikipage', 'path/to/a-wikipage', { :class => 'new_wiki_link' }
      helper.wikify_link('a wikipage')
    end
  
    it "links to wikipage_path" do
      helper.wikify_link('a wikipage').should have_tag('a[href=?]', 'path/to/a-wikipage')
    end
  end

  describe '#wiki_edit_links' do
      before :each do
        helper.extend RolesHelper
        helper.instance_variable_set(:@section, @section)
      end

    describe "with a home wikipage that is the current/last version" do
      before :each do
        @wikipage.stub!(:permalink).and_return 'home'
        @wikipage.stub!(:home?).and_return true
        @result = helper.wiki_edit_links(@wikipage)
      end

      it "should not contain a link to the wiki home page" do
        @result.should_not =~ /return to home/
      end

      it "should contain a link to edit the wikipage" do
        @result.should =~ /edit this page/
      end
      
      it "should not contain a link to rollback to this revision" do
        @result.should_not =~ /rollback to this revision/
      end
      
      it "should contain a link to view the previous revision" do
        @result.should =~ /view previous revision/
      end
      
      it "should not contain a link to view the next revision" do
        @result.should_not =~ /view next revision/
      end
    end

    describe "with a non-home wikipage that is the current/last version" do
      before :each do
        @result = helper.wiki_edit_links(@wikipage.versions.last)
      end
    
      it "should not use /wiki/pages/home as a home URL (but use /wiki instead)" do
        @result.should_not =~ %r(wiki/pages/home)
      end
    
      it "should contain a link to the wiki home page" do
        @result.should =~ /return to home/
      end
    
      it "should contain a link to edit the wikipage" do
        @result.should =~ /edit this page/
      end
    
      # delete link moved to the edit page
      # it "should contain a link to delete the wikipage" do
      #   @result.should =~ /delete this page/
      # end
    
      it "should not contain a link to rollback to this revision" do
        @result.should_not =~ /rollback to this revision/
      end
    
      it "should contain a link to view the previous revision" do
        @result.should =~ /view previous revision/
      end
    
      it "should not contain a link to view the next revision" do
        @result.should_not =~ /view next revision/
      end
    end
    
    describe "with a home wikipage that is the first version" do
      before :each do
        @wikipage.stub!(:permalink).and_return 'home'
        @result = helper.wiki_edit_links(@wikipage.versions.first)
      end
    
      it "should not contain a link to edit the wikipage" do
        @result.should_not =~ /edit this page/
      end
    
      it "should not contain a link to delete the wikipage" do
        @result.should_not =~ /delete this page/
      end
    
      it "should contain a link to rollback to this revision" do
        @result.should =~ /rollback to this revision/
      end
    
      it "should not contain a link to view the previous revision" do
        @result.should_not =~ /view previous revision/
      end
    
      it "should contain a link to view the next revision" do
        @result.should =~ /view next revision/
      end
    
      it "should contain a link to return to the current revision" do
        @result.should =~ /return to current revision/
      end
    
      it "should not use /wiki/pages/home as a current-version URL (but use /wiki instead)" do
        @result.last.should_not =~ %r(wiki/pages/home)
      end
    end
    
    describe "with a non-home wikipage that is the second version" do
      before :each do
        @wikipage.stub!(:version).and_return 2
        @result = helper.wiki_edit_links(@wikipage)
      end
    
      it "should contain a link to the wiki home page" do
        @result.should =~ /return to home/
      end
    
      it "should not contain a link to edit the wikipage" do
        @result.should_not =~ /edit this page/
      end
    
      # delete link moved to the edit page
      # it "should not contain a link to delete the wikipage" do
      #   @result.should_not =~ /delete this page/
      # end
    
      it "should contain a link to rollback to this revision" do
        @result.should =~ /rollback to this revision/
      end
    
      it "should contain a link to view the previous revision" do
        @result.should =~ /view previous revision/
      end
    
      it "should contain a link to view the next revision" do
        @result.should =~ /view next revision/
      end
    
      it "should contain a link to return to the current revision" do
        @result.should =~ /return to current revision/
      end
    end
    
    describe "a tag with the visible-for and user classes" do
      it "encloses the edit link" do
        @result = helper.wiki_edit_links(@wikipage)
        @result.should =~ /<[^>]* class="visible-for user[^>]*>[^<]*<a href="[^>]*edit"/
      end
    
      # delete link moved to the edit page
      # it "encloses the delete link" do
      #   @result = helper.wiki_edit_links(@wikipage)
      #   @result.should =~ /<[^>]* class="visible-for user[^>]*>[^<]*<a href="[^>]*a-wikipage"[^>]*delete/
      # end
    
      it "encloses the rollback link" do
        helper.stub!(:wikipage_path_with_home).and_return 'wikipage_path_with_home'
        @wikipage.stub!(:version).and_return 2
        @result = helper.wiki_edit_links(@wikipage)
        @result.should =~ /<[^>]* class="visible-for user[^>]*>[^<]*<a href="[^>]*wikipage_path_with_home"[^>]*rollback/
      end
    end
  end

  describe '#collection_title' do
    before(:each) do
      @category.stub!(:title).and_return('Category Title')
      @tags = ['Tag 1', 'Tag 2']
    end
  
    it "should show the full collection title if all parameters are given" do
      helper.collection_title(@category, @tags).should == "Pages about Category Title, tagged Tag 1 and Tag 2"
    end
  
    it "should show the collection title with category title if only category is given" do
      helper.collection_title(@category, nil).should == "Pages about Category Title"
    end
  
    it "should show the collection title with tags if only tags are given" do
      helper.collection_title(nil, @tags).should == "Pages tagged Tag 1 and Tag 2"
    end
  
    it "should show the default collection title if no parameters are given" do
      helper.collection_title(nil, nil).should == "All pages"
    end
  end
end