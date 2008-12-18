class Admin::DeletedIssuesController < Admin::BaseController
  def update
    @deleted_issue = DeletedIssue.find(params[:id])
    @deleted_issue.restore
    redirect_to admin_issues_path(@site, @deleted_issue.newsletter_id)
  end
end
