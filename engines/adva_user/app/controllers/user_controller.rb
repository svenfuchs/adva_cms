class UserController < BaseController
  renders_with_error_proc :below_field
  filter_parameter_logging :password

  layout 'simple'

  def new
    @user = User.new
  end

  def create
    @user = @site.users.build params[:user]
    if @site.save
      trigger_events @user, :registered
      render :action => 'verification_sent'
    else
      flash[:error] = t(:'adva.signup.flash.create.failure')
      render :action => :new
    end
  end

  def verification_sent
  end

  def verify
    if current_user.verify!
      set_user_cookie!
      trigger_event current_user, :verified
      flash[:notice] = t(:'adva.signup.flash.verify.success')
    else
      flash[:error] = t(:'adva.signup.flash.verify.failure')
    end
    redirect_to return_from(:verify)
  end

  def destroy
    current_user.destroy
    trigger_events current_user
    flash[:notice] = t(:'adva.signup.flash.destroy.success', :name =>  current_user.name)
    redirect_to '/'
  end

  private
    def url_with_token(user, purpose, params)
      token = user.assign_token purpose
      user.save
      url_for params.merge(:token => "#{user.id};#{token}")
    end
end
