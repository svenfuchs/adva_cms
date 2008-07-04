class Admin::SitesController < Admin::BaseController
  layout "admin"
  
  before_filter :params_site, :only => [:new, :create]
  before_filter :params_section, :only => [:new, :create]
  before_filter :protect_single_site_mode, :only => [:index, :new, :create, :destroy]
  
  cache_sweeper :site_sweeper, :only => [:create, :update, :destroy]

  authentication_required
  guards_permissions :site
  
  helper :activities
  
  def index
    @sites = Site.paginate(:page => params[:page], :per_page => params[:per_page], :order => 'id')
  end

  def show
    @users = @site.users_and_superusers
    @contents = @site.unapproved_comments.group_by(&:commentable)
    @activities = @site.activities.find_coinciding_grouped_by_dates(Time.zone.now.to_date, 1.day.ago.to_date)
  end
  
  def new
    @site = Site.new params[:site]
    @section = @site.sections.build params[:section]
  end

  def create
    @site = Site.new params[:site]
    @section = @site.sections.build(params[:section])
    @site.sections << @section
    
    if @site.save
      flash[:notice] = "The site has been created."
      redirect_to admin_site_path(@site)
    else
      flash.now[:error] = "The site could not be created"
      render :action => :new
    end
  end
  
  def edit
  end
 
  def update
    if @site.update_attributes params[:site]
      flash[:notice] = "The site has been updated."
      redirect_to edit_admin_site_path
    else
      flash.now[:error] = "The site could not be updated"
      render :action => 'edit'
    end
  end

  def destroy
    if @site.destroy
      flash[:notice] = "The site has been deleted."
      redirect_to admin_sites_path
    else
      flash.now[:error] = "The site could not be deleted"
      render :action => 'show'
    end
  end
  
  private
  
    def set_site
      @site = Site.find params[:id] if params[:id]
    end
    
    def params_site
      params[:site] ||= {} 
      params[:site].reverse_update :timezone => Time.zone.name, :host => request.host_with_port, :email => current_user.email, :comment_filter => 'smartypants_filter'
    end
    
    def params_section
      # TODO wtf ... reverse_update causes params[:section].delete(:type) to be nil?
      params[:section] = {:title => 'Home', :type => Section.types.first}.update(params[:section] || {})
    end
    
    def protect_single_site_mode
      unless Site.multi_sites_enabled
        if params[:action] == 'index'
          site = Site.find_or_initialize_by_host(request.host_with_port) 
          redirect_to admin_site_path(site)
        else
          render :action => :multi_sites_disabled, :layout => 'simple'
        end
      end
    end
end
