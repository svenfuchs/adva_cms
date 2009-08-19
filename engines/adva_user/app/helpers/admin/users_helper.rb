module Admin::UsersHelper
  def admin_users_path(*args)
    args.compact!
    args.first.is_a?(Site) ? admin_site_users_path(*args) : admin_global_users_path(*args)
  end

  def admin_users_url(*args)
    args.compact!
    args.first.is_a?(Site) ? admin_site_users_url(*args) : admin_global_users_url(*args)
  end

  def admin_user_path(*args)
    args.compact!
    args.first.is_a?(Site) ? admin_site_user_path(*args) : admin_global_user_path(*args)
  end

  def admin_user_url(*args)
    args.compact!
    args.first.is_a?(Site) ? admin_site_user_url(*args) : admin_global_user_url(*args)
  end

  def new_admin_user_path(*args)
    args.compact!
    args.first.is_a?(Site) ? new_admin_site_user_path(*args) : new_admin_global_user_path(*args)
  end

  def edit_admin_user_path(*args)
    args.compact!
    args.first.is_a?(Site) ? edit_admin_site_user_path(*args) : edit_admin_global_user_path(*args)
  end
end