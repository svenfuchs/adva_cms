factories :user

steps_for :user do
  Given "the user is logged in as $role" do |role|
    @user = create_user :name => role, :email => "#{role}@email.org", :login => role
    case role.to_sym
    when :admin
      @user.roles << Role.build(role.to_sym, Site.find(:first) || create_site)
    else      
      @user.roles << Role.build(role.to_sym)
    end
    @user.verified!
    
    post "/session", :user => {:login => @user.login, :password => @user.password}
  end
  
  Given "a user" do
    @user = User.find(:first) || create_user   
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
end