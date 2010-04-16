# FIXME clean up dependencies to rbac

class Admin::UsersController < Admin::BaseController
  include Admin::UsersHelper

  before_filter :set_users, :only => [:index]
  before_filter :set_user,  :only => [:show, :edit, :update, :destroy]
  before_filter :authorize_access
  before_filter :authorize_params, :only => :update
  before_filter :protect_delete_of_current_user, :only => :destroy
  filter_parameter_logging :password

  guards_permissions :user

  def new
    @invitation = Invitation.new
  end

  def index
  end

  def show
  end

  def create
    @invitation = @site.invitations.build(params[:invitation])
    @invitation.set_roles(params[:user][:roles_attributes])

    if @invitation.save
      UserMailer.deliver_user_invitation(user_confirmation_url(:token => @invitation.token),
        @invitation)
      flash[:notice] = t(:'adva.users.flash.invitation_success', :email => @invitation.email)
      redirect_to admin_users_url(@site)
    else
      render :action => :new
    end
  end

  def edit
  end

  def edit_profile
    @user = current_user
    if request.put?
      if @user.update_attributes(params[:user])
        flash[:notice] = t(:'adva.users.flash.update_profile.success')
      else
        flash.now[:error] = t(:'adva.users.flash.update_profile.failure')
      end
    end
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

  private

    def set_account
      @account = Site.find_by_id(params[:site_id]).account if params[:site_id]
    end

    def protect_delete_of_current_user
      if @user == current_user
        flash.now[:error] = t(:'adva.users.flash.destroy.failure')
        redirect_to admin_users_url(@site)
      end
    end

    def set_menu
      if params[:action] == 'edit_profile'
        @menu = Menus::Admin::Profile.new
      else
        @menu = Menus::Admin::Users.new
      end
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
