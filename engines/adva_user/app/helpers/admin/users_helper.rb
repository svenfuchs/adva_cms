module Admin::UsersHelper
  def admin_users_path(*args)
    args.first.is_a?(Site) ? admin_site_users_path(*args) : admin_global_users_path(*args)
  end
  
  def admin_user_path(*args)
    args.first.is_a?(Site) ? admin_site_user_path(*args) : admin_global_user_path(*args)
  end
end