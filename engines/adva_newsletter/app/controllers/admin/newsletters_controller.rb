class Admin::NewslettersController < Admin::BaseController
  def index
  end
  
  def show
    @newsletter = Newsletter.all_included.find(params[:id])
  end
  
  def new
    @newsletter = Newsletter.new
    @issue = Issue.new
  end
  
  def create
    @newsletter = Newsletter.new(params[:newsletter])
    
    if @newsletter.save
      @newsletter.issues.create(params[:issue]) if params[:draft].nil?
      redirect_to admin_newsletter_path(@site, @newsletter)
    else
      @issue ||= Issue.new
      render :action => 'new'
    end
  end
end
