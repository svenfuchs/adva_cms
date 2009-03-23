class Admin::IssuesController < Admin::BaseController
  content_for :'main_left', :issues_manage, :only => { :action => [:index, :show, :new, :edit] } do
    Menu.instance(:'admin.newsletters.manage').render(self)
  end

  content_for :'main_right', :issues_actions, :only => { :action => [:index, :show, :new, :edit] } do
    Menu.instance(:'admin.issues.actions').render(self)
  end

  guards_permissions :issue 

  before_filter :set_newsletter, :except => :index
  before_filter :set_issue, :except => [:index, :new, :create]

  def index
    @newsletter = Newsletter.all_included.find(params[:newsletter_id])
    @issues = @newsletter.issues
  end

  def show
  end

  def new
    @issue = Issue.new
  end

  def edit
    if !@issue.editable?
      flash[:error] = t(:"adva.messages.not_editable")
      redirect_to admin_issue_path(@site, @newsletter, @issue)
    end
  end

  def create
    @issue = @newsletter.issues.build(params[:issue])

    if @issue.save
      flash[:notice] = t(:"adva.newsletter.flash.issue_create_success")
      redirect_to admin_issue_path(@site, @newsletter, @issue)
    else
      render :action => "new"
    end
  end

  def update
    if @issue.update_attributes(params[:issue])
      flash[:notice] = t(:"adva.newsletter.flash.issue_update_success")
      redirect_to admin_issue_path(@site, @newsletter, @issue)
    else
      render :action => "edit"
    end
  end

  def destroy
    @issue.destroy
    flash[:notice] = t(:"adva.newsletter.flash.issue_moved_to_trash_success")
    redirect_to admin_issues_path(@site, @newsletter)
  end
  
private
  def set_newsletter
    @newsletter = Newsletter.find(params[:newsletter_id])
  end
  
  def set_issue
    @issue = Issue.find(params[:id])
  end
end
