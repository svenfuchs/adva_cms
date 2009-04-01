class SessionController < BaseController
  renders_with_error_proc :below_field
  
  skip_before_filter :verify_authenticity_token # disable forgery protection

  layout 'login'

  def new
    @user = User.new
  end

  def create
    if authenticate_user params[:user]
      remember_me! if params[:user][:remember_me]
      flash[:notice] = t(:'adva.session.flash.create.success')
      redirect_to return_from(:login)
    else
      @user = User.new :email => params[:user][:email]
      @remember_me = params[:user][:remember_me]
      flash.now[:error] = t(:'adva.session.flash.create.failure')
      render :action => 'new'
    end
  end

  def destroy
    logout
    flash[:notice] = t(:'adva.session.flash.destroy.success')
    redirect_to '/'
  end

  private
    # def reset_session_except(*keys)
    #   preserve = keys.map{|key| session[key] }
    #   reset_session
    #   preserve.each{|key, value| session[key] = value }
    # end
end
