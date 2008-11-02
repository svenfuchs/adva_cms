scenario :site_with_a_user do
  stub_scenario :empty_site

  @user = stub_user
  @users = stub_users
  @users.stub!(:paginate).and_return @users

  User.stub!(:new).and_return @user
  User.stub!(:find).and_return @user
  User.stub!(:paginate).and_return @users
  User.stub!(:admins_and_superusers).and_return @users
  Site.stub!(:paginate_users_and_superusers).and_return @users
end
