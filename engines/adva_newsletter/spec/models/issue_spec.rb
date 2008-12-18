require File.dirname(__FILE__) + '/../spec_helper'

describe BaseIssue do
  
  before :each do
    @issue = Factory :issue
  end

  describe "associations:" do  
    it "belongs to newsletter" do
      @issue.should belong_to(:newsletter)
    end
  end
  
  describe "validations:" do
    it "should have title" do
      @issue.title = nil
      @issue.should_not be_valid
    end
    
    it "should have body" do
      @issue.body = nil
      @issue.should_not be_valid
    end
  end
end

describe Issue do
  
  before :each do
    @issue = Factory :issue
  end

  describe "methods:" do
    describe "destroy" do
      it "should move Issue to DeletedIssue" do
        Issue.find_by_id(@issue.id).should_not == nil
        DeletedIssue.find_by_id(@issue.id).should == nil
        @issue.destroy
        Issue.find_by_id(@issue.id).should == nil
        DeletedIssue.find_by_id(@issue.id).should_not == nil
      end
      
      it "should decrease issues_count by -1" do
        @newsletter = Newsletter.first
        @newsletter.issues_count.should == 1
        @newsletter.issues.first.destroy
        @newsletter.reload.issues_count.should == 0
      end
    end
  end
end
