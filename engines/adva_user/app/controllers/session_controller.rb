class SessionController < BaseController
  skip_before_filter :set_site, :set_section, :set_cache_root

  authentication_required :except => [:new, :create]
  renders_with_error_proc :below_field

  layout 'login'

  def new
    @user = User.new
  end

  def create
    if authenticate_user params[:user]
      remember_me! if params[:user][:remember_me]
      flash[:notice] = 'Logged in successfully.'
      redirect_to return_from(:login)
    else
      @user = User.new :email => params[:user][:email]
      @remember_me = params[:user][:remember_me]
      flash.now[:error] = 'Could not login with this email and password.'
      render :action => 'new'
    end
  end

  def destroy
    logout
    flash[:notice] = 'Logged out successfully.'
    redirect_to request.relative_url_root.blank? ? '/' : request.relative_url_root
  end

  private
    # def reset_session_except(*keys)
    #   preserve = keys.map{|key| session[key] }
    #   reset_session
    #   preserve.each{|key, value| session[key] = value }
    # end
end
