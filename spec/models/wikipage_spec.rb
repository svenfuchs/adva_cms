require File.dirname(__FILE__) + '/../spec_helper'

describe Wikipage do  
  include Stubby, Matchers::ClassExtensions
  
  before :each do
    @wiki = stub_wiki
    @wikipage = Wikipage.new :section => @wiki, :author => stub_user
  end
  
  describe 'class extensions:' do
    it 'sanitizes the body attribute' do
      Wikipage.should filter_attributes(:sanitize => :body)
    end
    
    it 'does not sanitize the body_html attribute' do
      Wikipage.should filter_attributes(:except => [:body_html, :cached_tag_list])
    end
  end
  
  describe 'callbacks' do
    it 'sets its  attribute to the current time before create' do # TODO why does it do this??
      Wikipage.before_create.should include(:set_published)
    end
    
    it 'initializes the title from the permalink for new records that do not have a title' do
      wikipage = Wikipage.new :permalink => 'something-new'
      wikipage.title.should == 'Something new'
    end
  end
  
  describe '#accept_comments?' do
    it "accepts comments when the wiki accepts comments" do
      @wiki.should_receive(:accept_comments?).and_return true
      @wikipage.accept_comments?.should be_true
    end
  
    it "does not accept comments when the wiki doesn't" do
      @wiki.should_receive(:accept_comments?).and_return false
      @wikipage.accept_comments?.should be_false
    end
  end  
end