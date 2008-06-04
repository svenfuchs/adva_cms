class AccountController < BaseController
  authentication_required :except => [:new, :create]
  
  layout 'simple'

  def new
    @user = User.new
  end

  def create
    @user = @site.users.find_or_initialize_by_login_with_deleted params[:user]
    if @user.deleted_at
      restore
    elsif @user.new_record? and @user.save
      AccountMailer.deliver_signup_verification @user, verification_url(@user)
      render :action => 'verification_sent'
    else      
      flash[:error] = 'The user could not be registered.'
      render :action => :new    
    end
  end

  def restore
    if @user.restore!(params[:token])
      flash[:notice] = "Your user has been restored"
    else
      flash[:error] = "Your user could not be restored."
    end
    redirect_to '/'
  end


  def verify   
    if current_user.verified!
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
