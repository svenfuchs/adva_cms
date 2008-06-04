require File.dirname(__FILE__) + '/../spec_helper'

describe Wikipage do  
  include Stubby
  
  before :each do
    scenario :wiki, :user
    @wikipage = Wikipage.new :section => @wiki, :author => @user
  end
  
  it "should initialize the title from the given permalink for a new record" do
    wikipage = Wikipage.new :permalink => 'something-new'
    wikipage.title.should == 'Something new'
  end
  
  it "should generate a permalink from the title after validation" do
    wikipage = Wikipage.create! :title => 'Something new', :section => @wiki, :author => @user
    wikipage.permalink.should == 'something-new'
  end
  
  it "should create a new version when saved" do
    wikipage = Wikipage.create! :title => 'Something versioned', :section => @wiki, :author => @user
    wikipage.versions.last.should be_instance_of(Content::Version)
  end
  
  it "should accept comments when the wiki accepts comments" do
    @wiki.should_receive(:accept_comments?).and_return true
    @wikipage.accept_comments?.should be_true
  end
  
  it "should not accept comments when the wiki does not accept comments" do
    @wiki.should_receive(:accept_comments?).and_return false
    @wikipage.accept_comments?.should be_false
  end
  
end