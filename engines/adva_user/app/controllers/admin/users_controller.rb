class Admin::UsersController < Admin::BaseController
  before_filter :set_site
  before_filter :set_users, :only => [:index]
  before_filter :set_user,  :only => [:show, :edit, :update, :destroy]
  before_filter :authorize_access
  before_filter :authorize_params, :only => :update

  helper_method :collection_path, :member_path, :new_member_path, :edit_member_path

  guards_permissions :user, :except => [:show, :index]

  def index
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = @site ? @site.users.build : User.new
    if @user.update_attributes(params[:user])
      @user.verify! # TODO hu??
      trigger_events @user
      flash[:notice] = "The user account has been created."
      redirect_to member_path(@user)
    else
      flash.now[:error] = "The user account could not be created."
      render :action => :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes params[:user]
      trigger_events @user
      flash[:notice] = "The user account has been updated."
      redirect_to @user.is_site_member?(@site) ? member_path(@user) : collection_path
    else
      flash.now[:error] = "The user account could not be updated."
      render :action => :edit
    end
  end

  def destroy
    if @user.destroy
      trigger_events @user
      flash[:notice] = "The user account has been deleted."
      redirect_to collection_path
    else
      flash.now[:error] = "The user account could not be deleted."
      render :action => :edit
    end
  end

  private

    def set_site
      @site = Site.find(params[:site_id]) if params[:site_id]
    end

    def set_users
      @users = if @site
        @site.users_and_superusers.paginate :page => current_page
      else
        User.admins_and_superusers.paginate :page => current_page
      end
    end

    def set_user
      options = @site ? {:include => [:roles, :memberships], :conditions => ['memberships.site_id = ? OR roles.type = ?', @site.id, 'Rbac::Role::Superuser']} : {}
      @user = User.find params[:id], options
    end

    def authorize_access
      redirect_to admin_sites_path unless @site || current_user.has_role?(:superuser)
    end

    def authorize_params
      return
      return unless params[:user] && params[:user][:roles]

      if params[:user][:roles].has_key?('superuser') && !current_user.has_role?(:superuser) ||
         params[:user][:roles].has_key?('admin') && !current_user.has_role?(:admin, :context => @site)
        raise "unauthorized parameter" # TODO raise something more meaningful
      end
      # TODO as well check for membership site_id if !user.has_role?(:superuser)
    end

    def collection_path
      @site ? admin_site_users_path(@site.id) : admin_users_path
    end

    def member_path(user = nil)
      user ||= @user
      @site ? admin_site_user_path(@site.id, user) : admin_user_path(user)
    end

    def new_member_path
      @site ? new_admin_site_user_path(@site.id) : new_admin_user_path
    end

    def edit_member_path(user = nil)
      user ||= @user
      @site ? edit_admin_site_user_path(@site.id, user) : edit_admin_user_path(user)
    end
end
