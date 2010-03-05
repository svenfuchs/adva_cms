class Admin::SitesController < Admin::BaseController

  before_filter :params_site, :only => [:new, :create]
  before_filter :params_section, :only => [:new, :create]
  before_filter :protect_single_site_mode, :only => [:index, :new, :create, :destroy]

  cache_sweeper :site_sweeper, :only => [:create, :update, :destroy]

  guards_permissions :site

  helper :activities

  def index
    @sites = @account.sites
    @sites = @sites.paginate(:page => params[:page], :per_page => params[:per_page], :order => 'id')
  end

  def new
  end

  def show
    @users = @site.users_and_superusers
    @contents = @site.unapproved_comments.group_by(&:commentable)
    @activities = @site.activities.find_coinciding_grouped_by_dates(Time.zone.now.to_date, 1.day.ago.to_date)
  end

  def create
    site = Site.new params[:site]
    site.adva_best_account = @account
    section = site.sections.build(params[:section])
    site.sections << section
    if site.save
      @site = site
      flash[:notice] = t(:'adva.sites.flash.create.success')
      redirect_to admin_site_path(@site)
    else
      flash.now[:error] = t(:'adva.sites.flash.create.failure')
      render :action => :new, :account_id => @account
    end
  end

  def edit
  end

  # TODO: Tests missing
  def update
    if @site.update_attributes params[:site]
      flash[:notice] = t(:'adva.sites.flash.update.success')
      redirect_to edit_admin_site_url
    else
      flash.now[:error] = t(:'adva.sites.flash.update.failure')
      render :action => 'edit'
    end
  end

  # TODO: Tests missing
  def destroy
    if @site.destroy
      flash[:notice] = t(:'adva.sites.flash.destroy.success')
      redirect_to return_from(:site_deleted)
    else
      flash.now[:error] = t(:'adva.sites.flash.destroy.failure')
      render :action => 'show'
    end
  end

  protected

    def set_account
      # account_id only present for index action
      @account = Account.find_by_id(params[:account_id])
      # all other actions are in the scope of a site and the account can be found through the site
      @account = Site.find_by_id(params[:id]).adva_best_account unless @account
    end

    def set_menu
      @menu = case params[:action]
      when 'edit'
        Menus::Admin::Settings.new
      when 'new'
        Menus::Admin::Sites.new
      else
        Menus::Admin::Sites::Main.new
      end
    end

    def set_site
      @site = @account.sites.find(params[:id]) if params[:id] if @account
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

    def current_resource
      context = super
      context.new_record? ? @account : context
    end

    def protect_single_site_mode
      unless Site.multi_sites_enabled
        if params[:action] == 'index'
          site = Site.find_or_initialize_by_host(request.host_with_port)
          redirect_to admin_site_url(site)
        else
          render :action => :multi_sites_disabled, :layout => 'simple'
        end
      end
    end
end
