class Admin::DeletedIssuesController < Admin::BaseController
  guards_permissions :deleted_issue 

  def update
    @deleted_issue = DeletedIssue.find(params[:id])
    @deleted_issue.restore
    redirect_to admin_issues_path(@site, @deleted_issue.newsletter_id)
  end
end
