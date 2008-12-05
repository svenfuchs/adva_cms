class Admin::IssuesController < Admin::BaseController

  def index
    @newsletter = Newsletter.all_included.find(params[:newsletter_id])
    @issues = @newsletter.issues
  end
  
  def show
    @newsletter = Newsletter.find(params[:newsletter_id])
    @issue = Issue.find(params[:id])
  end
  
  def new
    @newsletter = Newsletter.find(params[:newsletter_id])
    @issue = Issue.new
  end
  
  def create
    @newsletter = Newsletter.find(params[:newsletter_id])
    @issue = @newsletter.issues.build(params[:issue])
    
    if @issue.save
      redirect_to admin_issue_path(@site, @newsletter, @issue)
    else
      render :action => 'new'
    end
  end
end
