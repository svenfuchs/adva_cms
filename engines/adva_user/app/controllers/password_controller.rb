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
      flash[:notice] = 'Notice sent. Please check your email.'
      redirect_to login_url
    else
      flash[:error] = 'Could not find a user with this email address.'
      render :action => :new
    end
  end
  
  def edit
  end

  def update
    if current_user.update_attributes(params[:user].slice(:password))
      trigger_event current_user, :password_updated
      flash[:notice] = 'Password successfully updated'
      redirect_to '/'
    else
      flash[:error] = 'Could not update the password'
      render :action => :edit
    end
  end
end
