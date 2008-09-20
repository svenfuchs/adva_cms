scenario :user_is_admin do
  raise "scenario :user_is_admin requires @user to be set" unless @user

  @admin_role = Role.build :admin, @site
  @user.roles.stub!(:by_context).and_return [@admin_role]
end