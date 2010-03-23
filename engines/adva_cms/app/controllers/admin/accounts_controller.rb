class Admin::AccountsController < Admin::BaseController

  # TODO rbac
  # guards_permissions :account

  authentication_required :except => [ :new, :create]
  before_filter :set_account, :except => [ :new, :create, :index ]
  before_filter :set_menu, :only => []

  def index
    @accounts = current_user.accounts
    @accounts = @accounts.paginate(:page => params[:page], :per_page => params[:per_page], :order => 'id')
    redirect_to admin_sites_url(:account_id => @accounts.first.id) if @accounts.total_entries == 1
  end

  def show
    @sites = @account.sites
    @sites = @sites.paginate(:page => params[:page], :per_page => params[:per_page], :order => 'id')
  end

  def new
    @user = User.new
    @account = Account.new
    @signup = true
  end

  def create
    @user = User.new(params[:user])
    @account = Account.new(params[:account])
    if existing_user = User.find_by_email(@user.email)
      unless existing_user.has_password?(params[:user][:password])
        flash[:error] = I18n.t(:'adva.accounts.signup.incorrect_password')
        return render(:action => 'new')
      end
      if @account.save
        existing_user.make_superuser(@account)
        authenticate_user(params[:user])
        trigger_events @account, :additional_account_created
        redirect_to(return_from(:login_backend))
      else
        render :action => 'new'
      end
    elsif user_and_account_valid?
      @account.save
      @user.save
      @user.make_superuser(@account)
      trigger_events @account, :registered
      render :action => 'verification_sent'
    else
      render :action => 'new'
    end
  end

  protected

  def set_account
    @account = Account.find(params[:id])
  end

  def url_with_token(user, purpose, params)
    token = user.assign_token purpose
    user.save
    verify_user_url(:token => "#{user.id};#{token}", :return_to => admin_sites_path(:account_id => @account))
  end

  private

  def user_and_account_valid?
    result = @user.valid?
    result &= @account.valid?
  end

end
