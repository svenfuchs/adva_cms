class Admin::IssueDeliveriesController < Admin::BaseController
  before_filter :set_newsletter, :except => :index

  def create
    @issue = Issue.find(params[:issue_id])
  end
  
  def preview
    @issue = Issue.find(params[:issue_id])

    if @issue.deliver(:to => current_user)
      flash[:notice] = t(:"adva.newsletter.flash.send_preview_issue")
    else
      flash[:error] = t(:"adva.newsletter.flash.send_preview_issue_failed")
    end
    redirect_to admin_issue_path(@site, @newsletter, @issue)
  end

private
  def set_newsletter
    @newsletter = Newsletter.find(params[:newsletter_id])
  end
end
