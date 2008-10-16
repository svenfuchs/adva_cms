require File.dirname(__FILE__) + '/../spec_helper'

describe "ActiveRecord", "original state:" do
  before :each do
    Site.delete_all
    @site = Site.create :host => 'example.com', :title => 'title', :name => 'name'
    @site.title = 'changed title'
  end

  it "does not break dirty tracking" do
    @site.title_was.should == 'title'
  end
  
  describe "#original_state" do
    before :each do
      @site.save
    end
    
    it "gets populated before save" do
      @site.original_state.should_not be_nil
    end
  
    it "remembers the original state #title_was as empty" do
      @site.original_state.title_was.should be_nil
    end
  
    it "remembers the original state #title_changed?" do
      @site.original_state.title_changed?.should be_true
    end
  
    it "remembers the original state #changed?" do
      @site.original_state.changed?.should be_true
    end
  
    it "contains the attribute values like they were saved before the last save" do
      @site.original_state.title.should == 'title'
    end
  end
  
  describe "#state_changes" do
    it "returns [:created] when original state was new record" do
      @site.state_changes.should == [:created]
    end
    
    it "returns [:updated] when original state was changed" do
      @site = Site.first
      @site.update_attributes :title => 'updated title'
      @site.state_changes.should == [:updated]
    end
    
    it "returns [:deleted] when original state was frozen" do
      @site.destroy
      @site.state_changes.should == [:deleted]
    end
    
    it "returns an empty array if no state changes are detected" do
      @site = Site.first
      @site.state_changes.should == []
    end
  end
end