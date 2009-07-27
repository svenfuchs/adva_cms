# FIXME clean up dependencies to rbac

class Admin::UsersController < Admin::BaseController
  include Admin::UsersHelper

  before_filter :set_users, :only => [:index]
  before_filter :set_user,  :only => [:show, :edit, :update, :destroy]
  before_filter :authorize_access
  before_filter :authorize_params, :only => :update
  filter_parameter_logging :password

  guards_permissions :user

  def index
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    # yuck! rails' params parsing is broken
    params[:user][:roles_attributes] = params[:user][:roles_attributes].map { |key, value| value } if params[:user][:roles_attributes]

    @user = User.new(params[:user])
    @user.memberships.build(:site => @site) if @site and !@user.has_role?(:superuser)

    if @user.save
      @user.verify! # TODO hu??
      trigger_events(@user)
      flash[:notice] = t(:'adva.users.flash.create.success')
      redirect_to admin_user_url(@site, @user)
    else
      flash.now[:error] = t(:'adva.users.flash.create.failure')
      render :action => :new
    end
  end

  def edit
  end

  def update
    # yuck! rails' params parsing is broken
    params[:user][:roles_attributes] = params[:user][:roles_attributes].map { |key, value| value } if params[:user][:roles_attributes]
    
    if @user.update_attributes(params[:user])
      trigger_events(@user)
      flash[:notice] = t(:'adva.users.flash.update.success')
      redirect_to admin_user_url(@site, @user)
    else
      flash.now[:error] = t(:'adva.users.flash.update.failure')
      render :action => :edit
    end
  end

  def destroy
    if @user.destroy
      trigger_events(@user)
      flash[:notice] = t(:'adva.users.flash.destroy.success')
      redirect_to admin_users_url(@site)
    else
      flash.now[:error] = t(:'adva.users.flash.destroy.failure')
      render :action => :edit
    end
  end

  private

    def set_menu
      @menu = Menus::Admin::Users.new
    end

    def set_users
      @users = @site ? @site.users_and_superusers.paginate(:page => current_page) :
                       User.admins_and_superusers.paginate(:page => current_page)
    end

    def set_user
      options = @site ? {:include => [:roles, :memberships], :conditions => ['memberships.site_id = ? OR roles.name = ?', @site.id, 'superuser']} : {}
      @user = User.find(params[:id], options)
    rescue
      flash[:error] = t(:'adva.users.flash.not_member_of_this_site')
      redirect_to admin_users_url(@site)
    end

    # FIXME extract this and use Rbac contexts instead
    def authorize_access
      redirect_to admin_sites_url unless @site || current_user.has_role?(:superuser)
    end

    def authorize_params
      return
      return unless params[:user] && params[:user][:roles]

      if params[:user][:roles].has_key?('superuser') && !current_user.has_role?(:superuser) ||
         params[:user][:roles].has_key?('admin') && !current_user.has_role?(:admin, @site)
        raise "unauthorized parameter" # TODO raise something more meaningful
      end
      # TODO as well check for membership site_id if !user.has_role?(:superuser)
    end
end
