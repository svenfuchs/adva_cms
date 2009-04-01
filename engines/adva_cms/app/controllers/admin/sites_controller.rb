class Admin::SitesController < Admin::BaseController
  layout "admin"

  before_filter :params_site, :only => [:new, :create]
  before_filter :params_section, :only => [:new, :create]
  before_filter :protect_single_site_mode, :only => [:index, :new, :create, :destroy]

  cache_sweeper :site_sweeper, :only => [:create, :update, :destroy]

  guards_permissions :site

  helper :activities

  def index
    @sites = Site.paginate(:page => params[:page], :per_page => params[:per_page], :order => 'id')
  end

  def show
    @users = @site.users_and_superusers # TODO wanna show only *recent* users here
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
      flash[:notice] = t(:'adva.sites.flash.create.success')
      redirect_to admin_site_path(@site)
    else
      flash.now[:error] = t(:'adva.sites.flash.create.failure')
      render :action => :new
    end
  end

  def edit
  end

  def update
    if @site.update_attributes params[:site]
      flash[:notice] = t(:'adva.sites.flash.update.success')
      redirect_to edit_admin_site_path
    else
      flash.now[:error] = t(:'adva.sites.flash.update.failure')
      render :action => 'edit'
    end
  end

  def destroy
    if @site.destroy
      flash[:notice] = t(:'adva.sites.flash.destroy.success')
      redirect_to return_from(:site_deleted)
    else
      flash.now[:error] = t(:'adva.sites.flash.destroy.failure')
      render :action => 'show'
    end
  end

  private

    def require_authentication
      required_role = @site ? :admin : :superuser
      unless current_user and current_user.has_role?(required_role, :context => current_resource) # TODO this is bad
        return redirect_to_login(t(:'adva.flash.authentication_required_role', :role => required_role))
      end
    end

    def set_site
      @site = Site.find params[:id] if params[:id]
    end

    def params_site
      params[:site] ||= {}
      params[:site][:timezone]       ||= Time.zone.name
      params[:site][:host]           ||= request.host_with_port
      params[:site][:email]          ||= current_user.email
      params[:site][:comment_filter] ||= 'smartypants_filter'
    end

    def params_section
      params[:section] ||= {}
      params[:section][:title] ||= 'Home'
      params[:section][:title] ||= Section.types.first
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
