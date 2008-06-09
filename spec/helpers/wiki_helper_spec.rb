require File.dirname(__FILE__) + '/../spec_helper'

describe WikiHelper do
  include Stubby
  include WikiHelper
  
  before :each do
    scenario :site, :section, :wiki, :wikipage
    @controller.instance_variable_set :@locale, 'en'
    stub!(:wikipage_path_with_home).and_return 'wikipage_path_with_home'
  end
  
  def controller
    @controller
  end
  
  it 'should have complete specs'
  
  describe "#wiki_edit_links with a home wikipage that is the current/last version" do
    before :each do
      @wikipage.stub!(:permalink).and_return 'home'
      @result = wiki_edit_links(@wikipage)
    end
    
    it "should not contain a link to the wiki home page" do
      @result.join.should_not =~ /return to home/
    end
    
    it "should contain a link to edit the wikipage" do
      @result.join.should =~ /edit this page/
    end
    
    it "should not contain a link to rollback to this revision" do
      @result.join.should_not =~ /rollback to this revision/
    end
    
    it "should contain a link to view the previous revision" do
      @result.join.should =~ /view previous revision/
    end
    
    it "should not contain a link to view the next revision" do
      @result.join.should_not =~ /view next revision/
    end
  end
  
  describe "#wiki_edit_links with a non-home wikipage that is the current/last version" do
    before :each do
      @result = wiki_edit_links(@wikipage.versions.last)
    end
    
    it "should not use /wiki/pages/home as a home URL (but use /wiki instead)" do
      @result.join.should_not =~ %r(wiki/pages/home)
    end
    
    it "should contain a link to the wiki home page" do
      @result.join.should =~ /return to home/
    end
  
    it "should contain a link to edit the wikipage" do
      @result.join.should =~ /edit this page/
    end
  
    it "should contain a link to delete the wikipage" do
      @result.join.should =~ /delete this page/
    end
    
    it "should not contain a link to rollback to this revision" do
      @result.join.should_not =~ /rollback to this revision/
    end
  
    it "should contain a link to view the previous revision" do
      @result.join.should =~ /view previous revision/
    end
  
    it "should not contain a link to view the next revision" do
      @result.join.should_not =~ /view next revision/
    end
  end
  
  describe "#wiki_edit_links with a home wikipage that is the first version" do
    before :each do
      @wikipage.stub!(:permalink).and_return 'home'
      @result = wiki_edit_links(@wikipage.versions.first)
    end
  
    it "should not contain a link to edit the wikipage" do
      @result.join.should_not =~ /edit this page/
    end

    it "should not contain a link to delete the wikipage" do
      @result.join.should_not =~ /delete this page/
    end
    
    it "should contain a link to rollback to this revision" do
      @result.join.should =~ /rollback to this revision/
    end
  
    it "should not contain a link to view the previous revision" do
      @result.join.should_not =~ /view previous revision/
    end
  
    it "should contain a link to view the next revision" do
      @result.join.should =~ /view next revision/
    end
  
    it "should contain a link to return to the current revision" do
      @result.join.should =~ /return to current revision/
    end
    
    it "should not use /wiki/pages/home as a current-version URL (but use /wiki instead)" do
      @result.last.should_not =~ %r(wiki/pages/home)
    end
  end
  
  describe "#wiki_edit_links with a non-home wikipage that is the second version" do
    before :each do
      @wikipage.stub!(:version).and_return 2
      @result = wiki_edit_links(@wikipage)
    end
    
    it "should contain a link to the wiki home page" do
      @result.join.should =~ /return to home/
    end
  
    it "should not contain a link to edit the wikipage" do
      @result.join.should_not =~ /edit this page/
    end
  
    it "should not contain a link to delete the wikipage" do
      @result.join.should_not =~ /delete this page/
    end
    
    it "should contain a link to rollback to this revision" do
      @result.join.should =~ /rollback to this revision/
    end
  
    it "should contain a link to view the previous revision" do
      @result.join.should =~ /view previous revision/
    end
  
    it "should contain a link to view the next revision" do
      @result.join.should =~ /view next revision/
    end
  
    it "should contain a link to return to the current revision" do
      @result.join.should =~ /return to current revision/
    end
  end
end