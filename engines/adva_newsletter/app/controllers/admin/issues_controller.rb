class Admin::IssuesController < Admin::BaseController
  guards_permissions :issue 

  before_filter :set_newsletter, :except => :index
  before_filter :set_issue, :except => [:index, :new, :create]

  def index
    @newsletter = Adva::Newsletter.all_included.find(params[:newsletter_id])
    @issues = @newsletter.issues.reload
  end

  def show
  end

  def new
    @issue = @newsletter.issues.build
  end

  def edit
    if !@issue.editable?
      flash[:error] = t(:"adva.messages.not_editable")
      redirect_to admin_adva_issue_path(@site, @newsletter, @issue)
    end
  end

  def create
    @issue = @newsletter.issues.build(params[:issue])

  if @issue.save
    flash[:notice] = t(:"adva.newsletter.flash.issue_create_success")
    redirect_to admin_adva_issue_path(@site, @newsletter, @issue)
    else
      render :action => "new"
    end
  end

  def update
    if @issue.update_attributes(params[:issue])
      flash[:notice] = t(:"adva.newsletter.flash.issue_update_success")
      redirect_to admin_adva_issue_path(@site, @newsletter, @issue)
    else
      render :action => "edit"
    end
  end

  def destroy
    @issue.destroy
    flash[:notice] = t(:"adva.newsletter.flash.issue_moved_to_trash_success")
    redirect_to admin_adva_issues_path(@site, @newsletter)
  end
  
  protected
  
    def set_menu
      @menu = Menus::Admin::Issues.new
    end

    def set_newsletter
      @newsletter = Adva::Newsletter.find(params[:newsletter_id])
    end
  
    def set_issue
      @issue = Adva::Issue.find(params[:id])
    end
end
