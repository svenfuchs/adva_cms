class Admin::AccountsController < Admin::BaseController

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
    @adva_best_account = AdvaBestAccount.new
    @signup = true
  end

  def create
    @user = User.new(params[:user])
    @adva_best_account = AdvaBestAccount.new(params[:adva_best_account])
    if existing_user = User.find_by_email(@user.email)
      unless existing_user.has_password?(params[:user][:password])
        flash[:error] = I18n.t(:'adva.accounts.signup.incorrect_password')
        return render(:action => 'new')
      end
      if @adva_best_account.save
        existing_user.make_superuser(@adva_best_account)
        authenticate_user(params[:user])
        trigger_events @adva_best_account, :additional_account_created
        redirect_to(return_from(:login_backend))
      else
        render :action => 'new'
      end
    elsif user_and_account_valid?
      @adva_best_account.save
      @user.save
      @user.make_superuser(@adva_best_account)
      trigger_events @adva_best_account, :registered
      render :action => 'verification_sent'
    else
      render :action => 'new'
    end
  end

  protected

  def set_account
    @account = AdvaBestAccount.find(params[:id])
  end

  def url_with_token(user, purpose, params)
    token = user.assign_token purpose
    user.save
    verify_user_url(:token => "#{user.id};#{token}", :return_to => admin_sites_path(:account_id => @adva_best_account))
  end

  private

  def user_and_account_valid?
    result = @user.valid?
    result &= @adva_best_account.valid?
  end

end
