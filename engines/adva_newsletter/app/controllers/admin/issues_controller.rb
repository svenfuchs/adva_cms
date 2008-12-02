class Admin::IssuesController < Admin::BaseController

  def index
  end
  
  def show
    @issue = Issue.find(params[:id])
  end
  
  def new
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
