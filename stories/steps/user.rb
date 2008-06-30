factories :user

steps_for :user do
  Given "the user is logged in as $role" do |role|
    @user = create_user :name => role, :email => "#{role}@email.org", :login => role
    @user.roles << Role.build(role.to_sym, Site.find(:first) || create_site)
    @user.verified!
    
    post "/session", :user => {:login => @user.login, :password => @user.password}
  end
  
  Given "a user" do
    @user = User.find(:first) || create_user     
  end
  
  Given "the user is verified" do
    @user.verified!
  end
  
  Given "the user is not verified" do
    @user.update_attributes! :verified_at => nil
  end
  
  When "the user is recognized as a recurring anonymous" do
    self.class.send :include, ActionController::AuthenticateAnonymous::InstanceMethods
    get '/' # seems to be necessary to open the integration session? how else can i do that?
    @anonymous = Anonymous.find(:first) || Anonymous.new(:name => 'anonymous', :email => 'anonymous@email.org')
    controller.instance_variable_set :@current_user, @anonymous
  end
  
  When "the user logs in with $credentials" do |credentials|
    post '/session', :user => credentials
  end
  
  Then "the system authenticates the user" do
    controller.current_user.should == @user
  end
  
  Then "the system does not authenticate the user" do
    controller.current_user.should be_nil
  end
end