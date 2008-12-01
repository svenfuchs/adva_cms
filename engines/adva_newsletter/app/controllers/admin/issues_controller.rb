class Admin::NewslettersController < Admin::BaseController
  def index
  end
  
  def show
    @issue = Issue.all_included.find(params[:id])
  end
  
  def new
    @issue = Issue.new
  end
  
  def create
    @issue = Issue.new(params[:newsletter])
    
    if @issue.save
      redirect_to admin_issue_path(@site, @issue)
    else
      render :action => 'new'
    end
  end
end
