class PasswordController < BaseController
  authentication_required :except => [:new, :create]

  layout 'simple'
  
  # send a reset password link
  def create
    if user = User.find_by_email(params[:email])
      PasswordMailer.deliver_reset_password user, reset_link(user)
      flash[:notice] = 'Notice sent. Please check your email.'
      redirect_to login_url
    else
      flash[:error] = 'Could not find a user with this email address.'
      render :action => :new
    end
  end

  # use a reset password link
  def update
    current_user.update_attributes!(params[:user].slice(:password, :password_confirmation))
    PasswordMailer.deliver_updated_password current_user, reset_link(current_user)
    flash[:notice] = 'Password successfully updated'
    redirect_to '/'
  rescue ActiveRecord::RecordInvalid => e
    @user = e.record
    render :action => 'edit'
  end

  private

    # return a link that will allow a user to reset their password
    def reset_link(user)
      token = user.assign_token 'password'
      user.save!
      token = "#{user.id};#{token}"
      reset_link = url_for :action => 'edit', :token => token
    end
end
