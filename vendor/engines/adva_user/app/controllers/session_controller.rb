class SessionController < BaseController
  authentication_required :except => [:new, :create]  
  renders_with_error_proc :below_field
  
  layout 'login'

  def new
    @user = User.new
  end

  def create
    if authenticate_user params[:user]
      remember_me! if params[:user][:remember_me]
      flash[:notice] = 'Login Successful'
      redirect_to session[:return_location] || '/'
      session[:return_location]
    else
      @user = User.new :login => params[:user][:login]
      @remember_me = params[:user][:remember_me]
      flash.now[:error] = 'Could not login with this login and password.'
      render :action => 'new'
    end
  end

  def destroy
    logout
    flash[:notice] = 'Logout Successful'
    redirect_to request.relative_url_root.blank? ? '/' : request.relative_url_root
  end

  private
  
    # def reset_session_except(*keys)
    #   preserve = keys.map{|key| session[key] }
    #   reset_session
    #   preserve.each{|key, value| session[key] = value }
    # end
end
