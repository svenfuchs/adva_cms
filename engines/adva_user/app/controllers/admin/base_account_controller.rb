class Admin::BaseAccountController < Admin::BaseController
  before_filter :set_account

  def set_account
    @account = current_user.account
  end

  def require_authentication
    unless current_user and current_user.account
      return redirect_to_login(t(:'adva.flash.authentication_required'))
    end
  end
end