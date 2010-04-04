class SessionController < BaseController
  renders_with_error_proc :below_field

  skip_before_filter :verify_authenticity_token # disable forgery protection

  layout 'login'

  def new
    @user = User.new(params[:user])
  end

  def create
    if (@site ? authenticate_user_for_site(@site, params[:user]) : authenticate_user(params[:user]))
      remember_me! if params[:user][:remember_me]
      flash[:notice] = t(:'adva.session.flash.create.success')
      @site ? redirect_to(return_from(:login_frontend)) : redirect_to(return_from(:login_backend))
    else
      @user = User.new(:email => params[:user][:email])
      @remember_me = params[:user][:remember_me]
      flash.now[:error] = t(:'adva.session.flash.create.failure')
      render :action => 'new'
    end
  end

  def destroy
    logout
    flash[:notice] = t(:'adva.session.flash.destroy.success')
    redirect_to login_url
  end
end
