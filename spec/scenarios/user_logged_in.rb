scenario :user_logged_in do
  @user = stub_model User, :id => 1, :registered? => true, :roles => []
  controller.stub!(:current_user).and_return @user
end