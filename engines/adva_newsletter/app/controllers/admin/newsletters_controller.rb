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
  
  def edit
    @newsletter = Newsletter.find(params[:id])
  end

  def create
    @newsletter = @site.newsletters.build(params[:newsletter])
    
    if @newsletter.save
      redirect_to admin_newsletter_path(@site, @newsletter)
    else
      render :action => 'new'
    end
  end
  
  def update
    @newsletter = Newsletter.find(params[:id])
    
    if @newsletter.update_attributes(params[:newsletter])
      flash[:notice] = t('adva.newsletter.flash.update_success')
      redirect_to admin_newsletter_path(@site, @newsletter)
    else
      render :action => 'edit'
    end
  end
end
