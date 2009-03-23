class Admin::NewslettersController < Admin::BaseController
  content_for :'main_left', :newsletters_manage, :only => { :action => [:index, :show, :new, :edit] } do
    Menu.instance(:'admin.newsletters.manage').render(self)
  end

  content_for :'main_right', :newsletters_actions, :only => { :action => [:index, :show, :new, :edit] } do
    Menu.instance(:'admin.newsletters.actions').render(self)
  end

  guards_permissions :newsletter 

  def index
    @newsletters = Newsletter.find(:all)
  end
  
  def show
    @newsletter = Newsletter.all_included.find(params[:id])
  end
  
  def new
    @newsletter = Newsletter.new
    @newsletter.email ||= @site.email
  end
  
  def edit
    @newsletter = Newsletter.find(params[:id])
    @newsletter.email ||= @newsletter.default_email
  end

  def create
    @newsletter = @site.newsletters.build(params[:newsletter])
    
    if @newsletter.save
      redirect_to admin_newsletters_path(@site)
    else
      render :action => 'new'
    end
  end
  
  def update
    @newsletter = Newsletter.find(params[:id])
    
    if @newsletter.update_attributes(params[:newsletter])
      flash[:notice] = t(:'adva.newsletter.flash.update_success')
      redirect_to admin_newsletters_path(@site)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @newsletter = Newsletter.find(params[:id])

    @newsletter.destroy
    flash[:notice] = t(:'adva.newsletter.flash.newsletter_moved_to_trash_success')
    redirect_to admin_newsletters_path(@site)
  end
end
