require File.dirname(__FILE__) + '/../spec_helper'

describe "ActiveRecord", "sticky changes:" do
  before :each do
    Site.delete_all
    @site = Site.create :host => 'example.com', :title => 'title', :name => 'name'
    @site.clear_changes!
  end

  it "does not break dirty tracking" do
    @site.title = 'changed title'
    @site.title_was.should == 'title'
  end
  
  describe "#state_changes" do
    it "returns [:created] when original state was new record" do
      @site = Site.create :host => '2.example.com', :title => 'title', :name => 'name'
      @site.state_changes.should == [:created]
    end
    
    it "returns [:updated] when original state was changed" do
      @site.update_attributes :title => 'updated title'
      @site.state_changes.should == [:updated]
    end
    
    it "returns [:deleted] when original state was frozen" do
      @site.destroy
      @site.state_changes.should == [:deleted]
    end
    
    it "returns an empty array if no state changes are detected" do
      @site.state_changes.should == []
    end
  end
end