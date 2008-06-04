class Admin::UsersController < Admin::BaseController
  before_filter :set_site
  before_filter :set_users, :only => [:index]
  before_filter :set_user,  :only => [:show, :edit, :update, :destroy]  
  before_filter :authorize_access
  before_filter :authorize_params, :only => :update  
  
  helper_method :collection_path, :member_path, :new_member_path, :edit_member_path
  
  def new
    @user = User.new
  end
  
  def create
    @user = @site ? @site.users.build : User.new    
    if @user.update_attributes(params[:user])
      @user.verified!
      @site.users << @user if @site
      flash[:notice] = "The user account has been created."
      redirect_to member_path(@user)
    else
      flash.now[:error] = "The user account could not be created."
      render :action => :new
    end
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "The user account has been updated."
      redirect_to member_path(@user)
    else
      flash.now[:error] = "The user account could not be updated."
      render :action => :edit
    end
  end
  
  def destroy
    if @user.destroy
      flash[:notice] = "The user account has been deactivated."
      redirect_to collection_path
    else
      flash.now[:error] = "The user account could not be deactivated."
      render :action => :edit
    end
  end
  
  private
  
    def set_site
      @site = Site.find(params[:site_id]) if params[:site_id]
    end
  
    def set_users
      @users = if @site
        Site.paginate_users_and_superusers @site.id, :page => params[:page]
      else
        User.paginate :page => params[:page]
      end
    end   
    
    def set_user
      options = @site ? {:include => [:roles, :memberships], :conditions => ['memberships.site_id = ? OR roles.name = ?', @site.id, 'superuser']} : {}
      @user = User.find params[:id], options
    end
    
    def authorize_access
      redirect_to admin_sites_path unless @site || current_user.has_role?(:superuser)
    end
    
    def authorize_params
      return unless params[:user] && params[:user][:roles]

      if params[:user][:roles].has_key?('superuser') && !current_user.has_role?(:superuser) ||
         params[:user][:roles].has_key?('admin') && !current_user.has_role?(:admin, @site)
        raise "unauthorized parameter" # TODO raise something more meaningful
      end
    end
  
    def collection_path
      @site ? admin_site_users_path : admin_users_path
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
