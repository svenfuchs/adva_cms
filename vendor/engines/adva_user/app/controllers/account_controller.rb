class AccountController < BaseController
  authentication_required :except => [:new, :create]
  renders_with_error_proc :below_field

  layout 'simple'

  def new
    @user = User.new
  end

  def create
    # TODO won't work any more because Site has_many users through memberships
    # and the membership will be deleted when the user is inactive?
    # @user = @site.users.find_or_initialize_by_login_with_deleted params[:user]
    @user = @site.users.build params[:user]
    if @user.deleted_at
      restore
    elsif @user.new_record? and @site.save
      AccountMailer.deliver_signup_verification @user, verification_url(@user)
      render :action => 'verification_sent'
    else
      flash[:error] = 'The user account could not be registered.'
      render :action => :new
    end
  end

  def verification_sent
  end

  def restore
    # was: params[:token].split(';').last
    # TODO this won't work because the salted hash thingy won't find a deleted user
    if @user.authenticate(params[:user][:password]) && @user.restore!
      flash[:notice] = "The user account has been restored"
    else
      flash[:error] = "The user account could not be restored."
    end
    redirect_to '/'
  end

  def verify
    if current_user.verify!
      flash[:notice] = "Successfully verified the E-mail address for #{current_user.name}"
    else
      flash[:notice] = "The E-mail address for #{current_user.name} is already verified."
    end
    redirect_to '/'
  end

  def destroy
    current_user.destroy
    AccountMailer.deliver_reactivate_user current_user, reactivation_url(current_user)
    flash[:notice] = "Successfully deleted user #{current_user.name}"
    redirect_to '/'
  end

  private

    def verification_url(user)
      url_with_token user, 'verification', :action => 'verify'
    end

    def reactivation_url(user)
      url_with_token user, 'reactivation', :action => 'create', :user => {:login => user.login}
    end

    def url_with_token(user, purpose, params)
      token = user.assign_token purpose
      user.save
      url_for params.merge(:token => "#{user.id};#{token}")
    end
end
