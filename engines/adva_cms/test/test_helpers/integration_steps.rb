ActionController::IntegrationTest.class_eval do
  def login_as(role)
    User.delete_all
    @user = Factory.create :user
    
    case role.to_sym
    when :admin
      @site ||= Site.find(:first) || Factory(:site)
      @site.users << @user
      @user.roles << Rbac::Role.build(role.to_sym, :context => @site)
    else
      @user.roles << Rbac::Role.build(role.to_sym)
    end
    @user.verify!

    post "/session", :user => {:email => @user.email, :password => @user.password}

    assert controller.authenticated?
  end
end