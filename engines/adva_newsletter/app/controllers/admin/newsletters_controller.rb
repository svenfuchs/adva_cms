class Admin::NewslettersController < Admin::BaseController

  def index
    @newsletters = Newsletter.all_included.find(:all)
  end
  
  def show
    @newsletter = Newsletter.all_included.find(params[:id])
  end
  
  def new
    @newsletter = Newsletter.new
  end
  
  def create
    @newsletter = Newsletter.new(params[:newsletter])
    
    if @newsletter.save
      redirect_to admin_newsletter_path(@site, @newsletter)
    else
      render :action => 'new'
    end
  end
end
