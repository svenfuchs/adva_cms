require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class UserLoginWithRememberMeTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
      @user = User.find_by_email('a-superuser@example.com')
      token = @user.assign_token!('remember me')
      cookies[:remember_me] = Rack::Utils.escape("#{@user.id};#{token}")
      cookies[:uid] = @user.id.to_s
      cookies[:uname] = @user.name
    end
    
    test "User with remember me cookie does not need to login again" do
      visit '/admin'
      assert_template 'admin/sites/show'
    end
  end
end