require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before :each do 
    @user = User.new :name => 'not-taken', 
                     :email => 'not-taken@email.org',
                     :login => 'not-taken', 
                     :password => 'not-taken', 
                     :password_confirmation => 'not-taken'
  end
  
  describe 'class extensions:' do
    it 'acts as paranoid'
    it 'acts as authenticated user'
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
      it '#by_site returns all superuser, site and section roles for the given user'
      it '#by_context returns all roles by_site for the given object'
      it '#by_context adds the implicit roles for the given object if it has any'
    end
  end
  
  describe 'callbacks:' do
    it 'saves associated roles after save' do
      User.after_save.should include(:save_roles)
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

    # TODO wtf - maybe rspec_on_rails_matchers are broken for Rails 2.1 or what?
    #
    # it "validates the uniqueness of the name" do
    #   @user.should validate_uniqueness_of(:name)
    # end
    # 
    # it "validates the uniqueness of the email" do
    #   @user.should validate_uniqueness_of(:email)
    # end
    # 
    # it "validates the uniqueness of the login" do
    #   @user.should validate_uniqueness_of(:login)
    # end
  
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
      it 'fails if no user with the given login exists'
      it 'calls authenticate on the user with the given password'
      it 'returns the user if user#authenticate succeeded'
      it 'returns false if user#authenticate failed'
    end
    
    it '.superusers returns all superusers' # TODO maybe it makes sense to move all of these to Role?

    describe '.create_superuser' do
      it 'creates a user'
      it 'verifies the user'
      it 'assigns the password' # TODO why is that needed?
      it 'adds a superuser role'
    end
  end
  
  describe 'instance methods' do
    it '#update_attributes temporarily stores roles (for saving in the callback)'
    it '#verified! sets the verified_at timestamp and saves the user'
    it '#restore! restores the user record'
    it '#anonymous? returns false'
    
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
    
    it '#to_s returns the name' # TODO hu? where's that used?
    
    it '#save_roles makes sure that the associated roles match the stored new roles'
  end
  
  
  
  
end