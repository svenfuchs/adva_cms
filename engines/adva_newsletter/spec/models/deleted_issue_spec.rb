require File.dirname(__FILE__) + '/../spec_helper'

describe DeletedIssue do
  
  before do
    Site.delete_all
    @deleted_issue = Factory :deleted_issue
  end

  describe "methods:" do
    describe "restore" do
      it "should restore DeleteIssue back to Issue" do
        Issue.find_by_id(@deleted_issue.id).should be_nil
        DeletedIssue.find_by_id(@deleted_issue.id).should_not be_nil
        @deleted_issue.restore
        Issue.find_by_id(@deleted_issue.id).should_not be_nil
        DeletedIssue.find_by_id(@deleted_issue.id).should be_nil
      end
      
      it "should increase issues_count by +1" do
        @newsletter = Newsletter.first
        @newsletter.issues_count.should == 0
        @newsletter.deleted_issues.first.restore
        @newsletter.reload.issues_count.should == 1
      end
    end
  end
end
