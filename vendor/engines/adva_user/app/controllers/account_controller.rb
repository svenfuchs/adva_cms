class AccountController < BaseController
  authentication_required :except => [:new, :create]
  renders_with_error_proc :below_field

  layout 'simple'

  def new
    @user = User.new
  end

  def create
    @user = @site.users.build params[:user]
    if @site.save
      trigger_event @user, :registered
      render :action => 'verification_sent'
    else
      flash[:error] = 'The user account could not be registered.'
      render :action => :new
    end
  end

  def verification_sent
  end

  # def restore
  #   # was: params[:token].split(';').last
  #   # TODO this won't work because the salted hash thingy won't find a deleted user
  #   if @user.authenticate(params[:user][:password]) && @user.restore!
  #     flash[:notice] = "The user account has been restored"
  #   else
  #     flash[:error] = "The user account could not be restored."
  #   end
  #   redirect_to '/'
  # end

  def verify
    if current_user.verify!
      trigger_event current_user, :verified
      flash[:notice] = "Successfully verified the E-mail address for #{current_user.name}"
    else
      flash[:error] = "The E-mail address for #{current_user.name} is already verified."
    end
    redirect_to '/'
  end

  def destroy
    current_user.destroy
    trigger_event current_user
    flash[:notice] = "Successfully deleted user #{current_user.name}"
    redirect_to '/'
  end

  def verification_url(user)
    url_with_token user, 'verification', :action => 'verify'
  end

  def reactivation_url(user)
    url_with_token user, 'reactivation', :action => 'create', :user => {:login => user.login}
  end

  private

    def url_with_token(user, purpose, params)
      token = user.assign_token purpose
      user.save
      url_for params.merge(:token => "#{user.id};#{token}")
    end
end
