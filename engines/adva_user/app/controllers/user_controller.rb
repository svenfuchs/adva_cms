class UserController < BaseController
  renders_with_error_proc :below_field
  filter_parameter_logging :password

  layout 'login'

  def new
    @user = User.new
  end

  def create
    @user = @site.users.build(params[:user])
    if @site.save
      trigger_events(@user, :registered)
      redirect_to user_verification_sent_url
    else
      flash[:error] = t(:'adva.signup.flash.create.failure')
      render :action => 'new'
    end
  end

  def verification_sent
    # TODO: translate text!
  end
  
  def confirm_invitation
    @invitation = Invitation.find_by_token(params[:token])
    if @invitation
      @user = User.find_by_email(@invitation.email)
      if @user
        @user.process_and_delete_invitation(@invitation)
        flash[:notice] = t("#{locale_key_prefix}.users.flash.existing_user_confirmed_invitation", :account_name => @invitation.site.account.name)
        redirect_to login_url(:user => { :email => @invitation.email })
      else
        if request.post?
          @user = User.new(params[:user].merge(:email => @invitation.email, :verified_at => Time.now))
          if @user.save
            @user.process_and_delete_invitation(@invitation)
            flash[:notice] = t("#{locale_key_prefix}.users.flash.confirmed_invitation", :account_name => @invitation.site.account.name)
            redirect_to login_url(:user => { :email => @invitation.email })
          end
        else
          @user = User.new(:email => @invitation.email)
        end
      end
    else
      flash[:notice] = t("#{locale_key_prefix}.users.flash.already_confirmed_invitation")
      redirect_to login_url
    end
  end

  def verify
    if current_user and current_user.verify!
      set_user_cookie!
      trigger_event(current_user, :verified)
      flash[:notice] = t(:'adva.signup.flash.verify.success')
    else
      flash[:error] = t(:'adva.signup.flash.verify.failure')
    end
    redirect_to params[:return_to]
  end

  def destroy
    current_user.destroy
    trigger_events(current_user)
    flash[:notice] = t(:'adva.signup.flash.destroy.success', :name =>  current_user.name)
    redirect_to '/'
  end

  private

  def locale_key_prefix
    'adva'
  end

  def url_with_token(user, purpose, params)
    token = user.assign_token purpose
    user.save
    url_for params.merge(:controller => 'user', :token => "#{user.id};#{token}", :return_to => root_path)
  end

end
