require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  include Stubby, Matchers::ClassExtensions
   
  before :each do 
    @user = User.new :name => 'not-taken', 
                     :email => 'not-taken@email.org',
                     :login => 'not-taken', 
                     :password => 'not-taken', 
                     :password_confirmation => 'not-taken'

    @time_now = Time.now
    Time.zone.stub!(:now).and_return @time_now
  end
  
  describe 'class extensions:' do
    it 'acts as paranoid' do
      User.should act_as_paranoid
    end
    
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
        scenario :user_has_several_roles    
      end
      
      it '#by_site returns all superuser, site and section roles for the given user' do
        roles = @user.roles.by_site(@site)
        roles.map(&:type).should == ['Role::Superuser', 'Role::Admin', 'Role::Moderator']
      end
      
      it '#by_context returns all roles by_site for the given object' do
        roles = @user.roles.by_context(@site)
        roles.map(&:type).should == ['Role::Superuser', 'Role::Admin', 'Role::Moderator']
      end
      
      it '#by_context adds the implicit roles for the given object if it has any' do
        @topic.stub!(:implicit_roles).and_return [@comment_author_role]
        roles = @user.roles.by_context(@topic)
        roles.map(&:type).should == ['Role::Superuser', 'Role::Admin', 'Role::Moderator', 'Role::Author']
      end
    end
  end
  
  describe 'validations:' do
    it "validates the presence of a name" do
      @user.should validate_presence_of(:name)
    end
  
    it "validates the presence of an email adress" do
      @user.should validate_presence_of(:email)
    end
  
    it "validates the presence of a login" do
      @user.should validate_presence_of(:login)
    end

    it "validates the uniqueness of the name" do
      @user.should validate_uniqueness_of(:name)
    end

    it "validates the uniqueness of the email" do
      @user.should validate_uniqueness_of(:email)
    end

    it "validates the uniqueness of the login" do
      @user.should validate_uniqueness_of(:login)
    end
  
    it "validates the length of the name" do
      @user.should validate_length_of(:name, :within => 1..40)
    end
  
    it "validates the presence of a password" do
      @user.should validate_presence_of(:password)
    end
  
    it "validates the presence of a password confirmation" do
      @user.should validate_presence_of(:password_confirmation)
    end
  
    it "validates the length of the password" do
      @user.should validate_length_of(:password, :within => 4..40)
    end
  
    it "validates the confirmation of the password" do
      @user.should validate_confirmation_of(:password)
    end
  end
  
  describe 'class methods' do
    describe '.authenticate' do
      before :each do
        User.stub!(:find_by_login).and_return @user
        @credentials = {:login => 'login', :password => 'password'}
      end
      
      it 'fails if no user with the given login exists' do
        User.should_receive(:find_by_login).with('login').and_return nil
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
        arg == :all &&
        (options[:conditions] & ['roles.type = ?', 'Role::Superuser']).size == 2 &&
        Array(options[:include]).include?(:roles)
      end
      User.superusers
    end

    describe '.create_superuser' do
      before :each do
        @attributes = {:login => 'login'}
        User.stub!(:new).and_return @user
        @user.stub!(:save)
        @user.stub!(:roles).and_return []
        Role::Superuser.stub!(:create)
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
        Role::Superuser.should_receive :create!
        @user.roles.should_receive(:<<)
        User.create_superuser @attributes
      end
    end
  end
  
  describe 'instance methods' do
    it '#attributes= calls update_roles if attributes have a :roles key' do
      @user.should_receive(:update_roles)
      @user.attributes= {:roles => 'roles'}
    end
    
    it '#verified! sets the verified_at timestamp and saves the user' do
      @user.should_receive(:update_attributes).with :verified_at => @time_now
      @user.verified!
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
    
    describe "#update_roles updates associated roles to match the given role parameters" do
      before :each do
        scenario :roles
        @user.stub!(:roles).and_return []
        Role.stub!(:create!).and_return stub_model(Role)
        @attributes = { 'roles' => { "0" => { "type" => "Role::Superuser", "selected" => "1" }, 
                                     "1" => { "type" => "Role::Admin", "context_id" => "1", "context_type" => "Site", "selected" => "1"} } }
      end
      
      it 'clears existing roles' do
        @user.roles.should_receive(:clear)
        @user.attributes = @attributes
      end
      
      it 'creates new roles' do
        Role.should_receive(:create!).twice
        @user.attributes = @attributes
      end
      
      it 'ignores parameters that do not have the :selected flag set' do
        @attributes['roles']['0']['selected'] = '0'
        Role.should_receive(:create!).once
        @user.attributes = @attributes
      end
    end
  end
end