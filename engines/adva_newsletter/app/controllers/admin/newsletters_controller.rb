class Admin::NewslettersController < Admin::BaseController
  guards_permissions :newsletter 

  def index
    @newsletters = Adva::Newsletter.find(:all)
  end
  
  def show
    @newsletter = Adva::Newsletter.all_included.find(params[:id])
  end
  
  def new
    @newsletter = Adva::Newsletter.new
  end
  
  def edit
    @newsletter = Adva::Newsletter.find(params[:id])
  end

  def create
    @newsletter = @site.newsletters.build(params[:newsletter])
    
    if @newsletter.save
      redirect_to admin_adva_newsletters_url(@site)
    else
      render :action => 'new'
    end
  end
  
  def update
    @newsletter = Adva::Newsletter.find(params[:id])
    
    if @newsletter.update_attributes(params[:newsletter])
      flash[:notice] = t(:'adva.newsletter.flash.update_success')
      redirect_to admin_adva_newsletters_url(@site)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @newsletter = Adva::Newsletter.find(params[:id])

    @newsletter.destroy
    flash[:notice] = t(:'adva.newsletter.flash.newsletter_moved_to_trash_success')
    redirect_to admin_adva_newsletters_url(@site)
  end
  
  protected
  
    def set_menu
      @menu = Menus::Admin::Newsletters.new
    end
end
