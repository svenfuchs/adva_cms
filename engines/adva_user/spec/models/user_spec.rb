require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  include Stubby, Matchers::ClassExtensions

  before :each do
    @user = User.new :first_name => 'not',
                     :last_name => 'taken',
                     :email => 'not-taken@email.org',
                     :password => 'not-taken'

    @time_now = Time.now
    Time.zone.stub!(:now).and_return @time_now
  end

  describe 'class extensions:' do
    it 'acts as authenticated user' do
      User.should act_as_authenticated_user
    end
  end

  describe 'associations:' do
    it "has many sites" do
      @user.should have_many(:sites)
    end

    it "has many memberships" do
      @user.should have_many(:memberships)
    end

    it "has many roles" do
      @user.should have_many(:roles)
    end

    describe 'the roles association' do
      before :each do
        stub_scenario :user_having_several_roles
      end

      it '#by_site returns all superuser, site and section roles for the given user' do
        roles = @user.roles.by_site(@site)
        roles.map(&:type).should == ['Rbac::Role::Superuser', 'Rbac::Role::Admin', 'Rbac::Role::Moderator']
      end

      it '#by_context returns all roles by_site for the given object' do
        roles = @user.roles.by_context(@site)
        roles.map(&:type).should == ['Rbac::Role::Superuser', 'Rbac::Role::Admin', 'Rbac::Role::Moderator']
      end

      it '#by_context adds the implicit roles for the given object if it has any' do
        @topic.stub!(:implicit_roles).and_return [@comment_author_role]
        roles = @user.roles.by_context(@topic)
        roles.map(&:type).should == ['Rbac::Role::Superuser', 'Rbac::Role::Admin', 'Rbac::Role::Moderator', 'Rbac::Role::Author']
      end
    end
  end

  describe 'validations:' do
    it "validates the presence of a first name" do
      @user.should validate_presence_of(:first_name)
    end

    it "validates the presence of an email adress" do
      @user.should validate_presence_of(:email)
    end

    it "validates the uniqueness of the email" do
      @user.should validate_uniqueness_of(:email)
    end

    it "validates the length of the last name" do
      @user.should validate_length_of(:last_name, :within => 0..40)
    end

    it "creates a user with blank last name" do
      @user.last_name = ''
      @user.save.should be_true
    end
    
    it "validates the length of the first name" do
      @user.should validate_length_of(:first_name, :within => 1..40)
    end

    it "validates the presence of a password" do
      @user.should validate_presence_of(:password)
    end

    it "validates the length of the password" do
      @user.should validate_length_of(:password, :within => 4..40)
    end

  end

  describe 'class methods' do
    describe '.authenticate' do
      before :each do
        User.stub!(:find_by_email).and_return @user
        @credentials = {:email => 'email@email.org', :password => 'password'}
      end

      it 'fails if no user with the given email exists' do
        User.should_receive(:find_by_email).with('email@email.org').and_return nil
        User.authenticate(@credentials).should be_false
      end

      it 'calls authenticate on the user with the given password' do
        @user.should_receive(:authenticate).with('password')
        User.authenticate @credentials
      end

      it 'returns the user if user#authenticate succeeded' do
        @user.stub!(:authenticate).and_return true
        User.authenticate(@credentials).should == @user
      end

      it 'returns false if user#authenticate failed' do
        @user.stub!(:authenticate).and_return nil
        User.authenticate(@credentials).should be_false
      end
    end

    it '.superusers returns all superusers' do
      User.should_receive(:find) do |arg, options|
        arg == :all and
        options[:conditions] == ['roles.type = ?', 'Rbac::Role::Superuser'] and
        Array(options[:include]).include?(:roles)
      end
      User.superusers
    end

    it '.admins_and_superusers returns all site admins and superusers' do
      User.should_receive(:find) do |arg, options|
        arg == :all and
        options[:conditions] == ['roles.type IN (?)', ['Rbac::Role::Superuser', 'Rbac::Role::Admin']] and
        Array(options[:include]).include?(:roles)
      end
      User.admins_and_superusers
    end
    
    describe '.create_superuser' do
      it 'should use email to generate empty first_name' do
        @user = User.create_superuser(:email => 'first.name@example.com')
        @user.first_name == 'first.name'
      end

      it 'should use default values if attributes are nil' do
        @user = User.create_superuser(:email => nil, :password => nil, :first_name => nil)
        @user.email.should == 'admin@example.org'
        @user.password.should == 'admin'
        @user.first_name == 'admin'
      end
      
      it 'should use params values' do
        @user = User.create_superuser(:email => 'test@example.org', :password => 'test', :first_name => 'name')
        @user.email.should == 'test@example.org'
        @user.password.should == 'test'
        @user.first_name == 'name'
      end
    end

    describe '.create_superuser (using mocks)' do
      before :each do
        @attributes = {:email => 'email@email.org'}
        User.stub!(:new).and_return @user
        @user.stub!(:save)
        @user.stub!(:roles).and_return []
        Rbac::Role::Superuser.stub!(:create)
      end

      it 'saves a new user without validation' do
        @user.should_receive(:save).with(false)
        User.create_superuser @attributes
      end

      it 'verifies the user' do
        @user.should_receive(:verified_at=).with @time_now
        User.create_superuser @attributes
      end

      it 'assigns the password' do # TODO why is that needed?
        @user.should_receive :assign_password
        User.create_superuser @attributes
      end

      it 'adds a superuser role' do
        Rbac::Role::Superuser.should_receive :create!
        @user.roles.should_receive(:<<)
        User.create_superuser @attributes
      end
    end

    describe ".by_context_and_role" do
      it "finds all admins of a given site" do
        User.should_receive(:find) do |arg, options|
          arg == :all &&
          options[:conditions] == ["roles.context_type = ? AND roles.context_id = ? AND roles.type = 'Rbac::Role::?'", stub_site.class, stub_site.id, 'Admin'] &&
          Array(options[:include]).include?(:roles)
        end
        User.by_context_and_role(stub_site, 'Admin')
      end

      it "finds all admins of a given site when admin role is passed as a symbol" # TODO: necessary?

      it "finds all admins of a given site when admin role is passed as a lower case string" # TODO: necessary?

      it "finds all superusers" do
        User.should_receive(:superusers)
        User.by_context_and_role(stub_site, 'Superuser')
      end
    end
  end

  describe 'instance methods' do
    it '#attributes= calls update_roles if attributes have a :roles key' do
      @user.should_receive(:update_roles)
      @user.attributes= {:roles => 'roles'}
    end

    it '#verify! sets the verified_at timestamp and saves the user' do
      @user.should_receive(:update_attributes).with :verified_at => @time_now
      @user.verify!
    end

    it '#restore! restores the user record' do
      @user.deleted_at = @time_now
      @user.should_receive(:update_attributes).with :deleted_at => nil
      @user.restore!
    end

    it '#anonymous? returns false' do
      User.new.anonymous?.should be_false
    end

    describe '#registered?' do
      it 'returns true when the record is not new' do
        @user.stub!(:new_record?).and_return false
        @user.registered?.should be_true
      end

      it 'returns false when the record is new' do
        @user.stub!(:new_record?).and_return true
        @user.registered?.should be_false
      end
    end

    it '#to_s returns the name' do # TODO hu? where's that used?
      @user.to_s.should == @user.name
    end
    
    it "#homepage returns the http://homepage is homepage is set to 'homepage'" do
      @user.homepage ='homepage'
      @user.homepage.should == 'http://homepage'
    end
    
    it "#homepage returns the http://homepage is homepage is set to 'http://homepage'" do
      @user.homepage ='http://homepage'
      @user.homepage.should == 'http://homepage'
    end
    
    it "#homepage returns nil if homepage is not set" do
      @user.homepage.should == nil
    end

    describe "#update_roles updates associated roles to match the given role parameters" do
      before :each do
        stub_scenario :roles
        @user.stub!(:roles).and_return []
        Site.stub!(:find).and_return Site.new(:id => 1)
        @attributes = { 'roles' => { "0" => { "type" => "Rbac::Role::Superuser", "selected" => "1" },
                                     "1" => { "type" => "Rbac::Role::Admin", "context_id" => "1", "context_type" => "Site", "selected" => "1"} } }
      end

      it 'clears existing roles' do
        @user.roles.should_receive(:clear)
        @user.attributes = @attributes
      end

      it 'creates new roles' do
        Rbac::Role::Admin.should_receive(:create!)
        Rbac::Role::Superuser.should_receive(:create!)
        @user.attributes = @attributes
      end

      it 'ignores parameters that do not have the :selected flag set' do
        @attributes['roles']['0']['selected'] = '0'
        Rbac::Role::Admin.should_receive(:create!)
        @user.attributes = @attributes
      end
    end
  end
end
