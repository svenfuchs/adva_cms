require File.dirname(__FILE__) + '/../spec_helper'

describe BaseNewsletter do
  
  before :each do
    @issue = Factory :newsletter
  end

  describe "validations:" do
    it "should have title" do
      @issue.title = nil
      @issue.should_not be_valid
    end
  end
end

describe Newsletter do
  
  before do
    @newsletter = Factory :newsletter
  end

  describe "methods:" do
    describe "destroy" do
      it "should move Newsletter to DeletedNewsletter" do
        Newsletter.find_by_id(@newsletter.id).should_not == nil
        DeletedNewsletter.find_by_id(@newsletter.id).should == nil
        @newsletter.destroy
        Newsletter.find_by_id(@newsletter.id).should == nil
        DeletedNewsletter.find_by_id(@newsletter.id).should_not == nil
      end
    end
  end
end
