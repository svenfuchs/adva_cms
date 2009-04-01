class PasswordController < BaseController
  renders_with_error_proc :below_field

  layout 'simple'

  def new
  end

  def create
    if user = User.find_by_email(params[:user][:email])
      token = user.assign_token 'password'
      user.save!
      trigger_event user, :password_reset_requested, :token => "#{user.id};#{token}"
      flash[:notice] = t(:'adva.passwords.flash.new.email_sent')
      redirect_to login_url
    else
      flash[:error] = t(:'adva.passwords.flash.new.no_such_user')
      render :action => :new
    end
  end

  def edit
  end

  def update
    if current_user.update_attributes(params[:user].slice(:password))
      trigger_event current_user, :password_updated
      flash[:notice] = t(:'adva.passwords.flash.update.success')
      redirect_to '/'
    else
      flash[:error] = t(:'adva.passwords.flash.update.failure')
      render :action => :edit
    end
  end
end
