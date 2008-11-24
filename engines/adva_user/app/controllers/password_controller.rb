class PasswordController < BaseController
  authentication_required :except => [:new, :create]
  renders_with_error_proc :below_field

  layout 'simple'

  def new
  end

  def create
    if user = User.find_by_email(params[:user][:email])
      token = user.assign_token 'password'
      user.save!
      trigger_event user, :password_reset_requested, :token => "#{user.id};#{token}"
      flash[:notice] = 'We just sent you a notice. Please check your email.'
      redirect_to login_url
    else
      flash[:error] = 'We could not find a user with the email address you entered.'
      render :action => :new
    end
  end

  def edit
  end

  def update
    if current_user.update_attributes(params[:user].slice(:password))
      trigger_event current_user, :password_updated
      flash[:notice] = 'Your password was changed successfully.'
      redirect_to '/'
    else
      flash[:error] = 'Your password could not be changed.'
      render :action => :edit
    end
  end
end
