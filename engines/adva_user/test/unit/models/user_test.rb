require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class UserTest < ActiveSupport::TestCase
  def setup
    super
    @user = User.find_by_first_name('a user')
    @credentials = { :email => @user.email, :password => 'a password' }
    @valid_user_params = { :email => 'test@example.org', :password => 'test', :first_name => 'name' }
  end

  test 'acts as authenticated user' do
    User.should act_as_authenticated_user
  end

  # ASSOCIATIONS

  test "has many sites" do
    @user.should have_many(:sites)
  end

  test "has many memberships" do
    @user.should have_many(:memberships)
  end

  test "has many roles" do
    @user.should have_many(:roles)
  end

  # VALIDATIONS

  test "validates the presence of a first name" do
    @user.should validate_presence_of(:first_name)
  end

  test "validates the presence of an email adress" do
    @user.should validate_presence_of(:email)
  end

  test "validates the uniqueness of the email" do
    @user.should validate_uniqueness_of(:email)
  end

  test "validates the presence of a password if the password is required" do
    @user.should validate_presence_of(:password, :if => :password_required?)
  end

  test "validates the length of the last name" do
    @user.should validate_length_of(:last_name, :within => 0..40)
  end

  test "creates a user with blank last name" do
    @user.last_name = ''
    @user.save.should be_true
  end

  test "validates the length of the first name" do
    @user.should validate_length_of(:first_name, :within => 1..40)
  end

  test "validates the length of the password" do
    @user.should validate_length_of(:password, :within => 4..40)
  end

  # CLASS METHODS

  # User.authenticate
  test 'User.authenticate returns the user if user#authenticate succeeds' do
    User.authenticate(@credentials).should == @user
  end

  test 'User.authenticate returns false if user#authenticate fails' do
    @credentials[:email] = 'does_not_exist@email.org'
    User.authenticate(@credentials).should be_false
  end

  test 'User.authenticate returns false if no user with the given email exists' do
    @credentials[:password] = 'wrong password'
    User.authenticate(@credentials).should be_false
  end
  
  # User.admins_and_superusers
  test 'User.admins_and_superusers returns all site admins and superusers' do
    admin = User.find_by_first_name('an admin')
    superuser = User.find_by_first_name('a superuser')

    result = User.admins_and_superusers
    result.should include(admin)
    result.should include(superuser)
    # result.size.should == 2
  end

  # User.create_superuser
  test 'User.create_superuser defaults :first_name to the name part of the email' do
    user = User.create_superuser(:email => 'first.name@example.com')
    user.first_name == 'first.name'
  end

  test 'User.create_superuser uses default values for email and password' do
    user = User.create_superuser(:email => nil, :password => nil, :first_name => nil)
    user.email.should == 'admin@example.org'
    user.password.should == 'admin'
  end

  test 'User.create_superuser uses params values if given' do
    user = User.create_superuser(@valid_user_params)
    user.email.should == 'test@example.org'
    user.password.should == 'test'
    user.first_name == 'name'
  end

  test 'User.create_superuser verifies the user' do
    user = User.create_superuser(@valid_user_params)
    user.verified?.should be_true
  end

  test 'User.create_superuser saves the user' do
    user = User.create_superuser(@valid_user_params)
    user.new_record?.should be_false
  end

  test 'assigns the password hash' do
    user = User.create_superuser(@valid_user_params)
    user.password_hash.should_not be_blank
    user.password_salt.should_not be_blank
  end
  
  # INSTANCE METHODS
  
  test '#verify! sets the verified_at timestamp and saves the user' do
    @user.update_attributes(:verified_at => nil)
    @user.verify!
    @user.reload.verified_at.should_not be_nil
  end

  # test '#restore! restores the user record' do
  #   @user.deleted_at = @time_now
  #   @user.should_receive(:update_attributes).with :deleted_at => nil
  #   @user.restore!
  # end

  test '#anonymous? returns true when anonymous is true' do
    User.new(:anonymous => true).anonymous?.should be_true
    User.new.anonymous?.should be_false
  end

  # registered?
  test '#registered? returns true when the record is not new' do
    @user.registered?.should be_true
    User.new.registered?.should be_false
  end

  test '#to_s returns the name' do # FIXME hu? where's that used?
    @user.to_s.should == @user.name
  end

  test "#homepage returns the http://homepage is homepage is set to 'homepage'" do
    @user.homepage ='homepage'
    @user.homepage.should == 'http://homepage'
  end

  test "#homepage returns the http://homepage is homepage is set to 'http://homepage'" do
    @user.homepage ='http://homepage'
    @user.homepage.should == 'http://homepage'
  end

  test "#homepage returns nil if homepage is not set" do
    @user.homepage.should be_nil
  end

  test "#email_with_name returns formatted string to use with email headers" do
    @user.email_with_name.should == "a user <a-user@example.com>"
  end
end
