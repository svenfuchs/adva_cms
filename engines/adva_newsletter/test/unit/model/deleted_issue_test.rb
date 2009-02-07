require File.dirname(__FILE__) + '/../../test_helper'

class DeletedIssueTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.find_by_name("site with newsletter")
    @newsletter = @site.newsletters.first
    @deleted_issue = @newsletter.deleted_issues.create! :title => "deleted issue title",
                                                        :body => "deleted issue body",
                                                        :deleted_at => Time.now
  end
  
  test "#restore should restore DeletedIssue back to Issue" do
    Issue.find_by_id(@deleted_issue.id).should be_nil
    DeletedIssue.find_by_id(@deleted_issue.id).should_not be_nil
    @deleted_issue.restore
    Issue.find_by_id(@deleted_issue.id).should_not be_nil
    DeletedIssue.find_by_id(@deleted_issue.id).should be_nil
  end
  
  test "#restor should increase issues_count by +1" do
    @newsletter.issues_count.should == 1
    @deleted_issue.restore
    @newsletter.reload.issues_count.should == 2
  end
end
