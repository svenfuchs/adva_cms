factories :user

steps_for :user do
  Given "the user is logged in as $role" do |role|
    @user = create_user :name => role, :email => "#{role}@email.org", :login => role
    case role.to_sym
    when :admin
      @site ||= Site.find(:first) || create_site
      @site.users << @user
      @user.roles << Role.build(role.to_sym, @site)
    else      
      @user.roles << Role.build(role.to_sym)
    end
    @user.verified!
    
    post "/session", :user => {:login => @user.login, :password => @user.password}
  end
  
  Given "a user" do
    @user = User.find(:first) || create_user   
  end
  
  Given "another user" do
    @other_user = create_user :name => 'another user name', :email => 'another_user@email.org', :login => 'another-login', :password => 'password', :password_confirmation => 'password'
  end
  
  Given "the other user is a member of the site" do
    @site.users << @other_user
  end
  
  Given "an unverified user" do
    @user = User.find(:first) || create_user   
    @user.update_attributes! :verified_at => nil
  end  
  
  Given "no user exists" do
    User.delete_all!
  end
  
  Given "the user is verified" do
    @user.verified!
  end
  
  Given "the user is not verified" do
    @user.update_attributes! :verified_at => nil
  end
  
  Given "no anonymous accounts exist" do
    Anonymous.delete_all
  end
  
  When "the user logs in with $credentials" do |credentials|
    post '/session', :user => credentials
  end
  
  When "the user verifies his account" do
    token = @user.assign_token! 'verify'
    AccountController.hidden_actions.delete 'verify'
    AccountController.instance_variable_set(:@action_methods, nil)
    get "/account/verify?token=#{@user.id}%3B#{token}"    
    @user = controller.current_user
  end
  
  Then "a user exists" do
    @user = User.find :first
    @user.should_not be_nil
  end
  
  Then "the user is verified" do
    @user.verified?.should be_true
  end
  
  Then "the user is not verified" do
    @user.verified?.should be_false
  end
  
  Then "an anonymous account exists" do
    @anonymous = Anonymous.find(:first)
    @anonymous.should_not be_nil
  end
  
  Then "the system authenticates the user" do
    controller.current_user.should == @user
  end
  
  Then "the system does not authenticate the user" do
    controller.current_user.should be_nil
  end
  
  Then "the system authenticates the user as a known anonymous" do
    controller.current_user.should == @anonymous
  end    

  Then "a verification email is sent to the user's email address" do
    ActionMailer::Base.deliveries.first
  end
  
  # TODO somehow namespace these to: admin
  
  When "the user visits the site's user list page" do
    get admin_site_users_path(@site)
    response.should be_success
  end
  
  When "the user visits the other user's show page" do
    get admin_site_user_path(@site, @other_user)
    response.should be_success
  end
  
  When "the user fills in the user account creation form with valid values" do
    fills_in 'name', :with => 'a new user name'
    fills_in 'email', :with => 'new_user@email.org'
    fills_in 'login', :with => 'new_user'
    fills_in 'password', :with => 'password'
    fills_in 'password confirmation', :with => 'password'
  end
  
  Then "a new user account is created" do 
    User.find_by_name('a new user name').should_not be_nil
  end
  
  Then "the other user's name is 'an updated name'" do
    @other_user.reload
    @other_user.name.should == 'an updated name'
  end
  
  Then "the page has a user account creation form" do
    action = admin_site_users_path(@site)
    response.should have_form_posting_to(action)
  end
  
  Then "the page has a user account edit form" do
    action = admin_site_user_path(@site, @other_user)
    response.should have_form_putting_to(action)
  end
  
  Then "the user is redirected to a site's user show page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/users/[\d]*)
    response.should render_template('admin/users/show')
  end
end