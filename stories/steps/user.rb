factories :user

steps_for :user do
  Given "no anonymous account exists" do
    User.delete_all 'anonymous = 1'
  end

  Then "an anonymous account exists" do
    @anonymous = User.find_by_anonymous(true)
    @anonymous.should_not be_nil
  end

  Given "no user exists" do
    User.delete_all
    @user_count = 0
  end

  Given "a user" do
    @user = User.find(:first) || create_user
    @user_count = 1
  end

  Given "another user" do
    @other_user = create_user :name => 'another user name', :email => 'another_user@email.org', :password => 'password'
  end

  Given "the other user is a member of the site" do
    @site.users << @other_user
  end

  Given "a site admin and a site member account" do
    @site ||= Site.find(:first) || create_site

    @admin = create_user  :name => 'admin name', :email => 'admin@email.org', :password => 'password'
    @site.users << @admin
    @admin.roles << Rbac::Role.build(:admin, :context => @site)

    @user = create_user :name => 'another user name', :email => 'another_user@email.org', :password => 'password'
    @site.users << @user
  end

  # ADMIN VIEWS

  When "the user visits the global user list in the admin interface" do
    get admin_users_path
    response.should be_success
  end

  When "the user visits the site's user list in the admin interface" do
    get admin_site_users_path(@site)
    response.should be_success
  end

  When "the user visits the admin site other user show page" do
    get admin_site_user_path(@site, @other_user)
    response.should be_success
  end

  When "the user fills in the admin user account creation form with valid values" do
    fills_in 'first name', :with => "a new user's first name"
    fills_in 'last name', :with => "a new user last name"
    fills_in 'email', :with => 'new_user@email.org'
    fills_in 'password', :with => 'password'
  end

  Then "a new user account is created" do
    @user = User.find_by_first_name("a new user's first name")
    @user.should_not be_nil
  end

  Then "the user is a member of the site" do
    @user.is_site_member?(@site).should be_true
  end

  Then "an admin account is created" do
    User.count.should == 1
    @user = User.find_by_name('Admin')
    @user.should_not be_nil
  end

  Then "the admin account is verified" do
    @user.verified?.should be_true
  end

  Then "the other user's name is 'an updated name'" do
    @other_user.reload
    @other_user.name.should == 'an updated name'
  end

  Then "the page shows a list of users with $count entries" do |count|
    response.should have_tag('ul[class=?]', 'users') do |ul|
      ul.should have_tag('li', :count => count.to_i)
    end
  end

  Then "the page has an admin user account creation form" do
    action = admin_site_users_path(@site)
    response.should have_form_posting_to(action)
  end

  Then "the page has an admin user account edit form" do
    action = admin_site_user_path(@site, @other_user)
    response.should have_form_putting_to(action)
  end

  Then "the user is redirected to the admin site user show page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/users/[\d]*)
    response.should render_template('admin/users/show')
  end
end
