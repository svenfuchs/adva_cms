class Admin::DeletedIssuesController < Admin::BaseController
  guards_permissions :deleted_issue 

  # TODO: update the code when this functionality is needed
  # def update
    # @deleted_issue = DeletedIssue.find(params[:id])
    # @deleted_issue.restore
    # redirect_to admin_adva_issues_url(@site, @deleted_issue.newsletter_id)
  # end
end
