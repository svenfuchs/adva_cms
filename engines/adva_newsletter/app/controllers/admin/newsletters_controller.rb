class Admin::NewslettersController < Admin::BaseController

  guards_permissions :newsletter

  before_filter :set_newsletters, :only => :index
  before_filter :set_newsletter, :only => [:edit, :update, :destroy]

  def index
  end

  def show
    @newsletter = @site.newsletters.all_included.find(params[:id])
  end

  def new
    @newsletter = Adva::Newsletter.new
  end

  def edit
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
    if @newsletter.update_attributes(params[:newsletter])
      flash[:notice] = t(:'adva.newsletter.flash.update_success')
      redirect_to admin_adva_newsletters_url(@site)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @newsletter.destroy
    flash[:notice] = t(:'adva.newsletter.flash.newsletter_moved_to_trash_success')
    redirect_to admin_adva_newsletters_url(@site)
  end

  protected

    def set_menu
      @menu = Menus::Admin::Newsletters.new
    end

    def set_newsletter
      @newsletter = @site.newsletters.find(params[:id])
    end

    def set_newsletters
      @newsletters = @site.newsletters
    end
end
