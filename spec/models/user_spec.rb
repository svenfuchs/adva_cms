require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  # fixtures :users
  
  before :each do 
    @user = User.new :name => 'not-taken', 
                     :email => 'not-taken@email.org',
                     :login => 'not-taken', 
                     :password => 'not-taken', 
                     :password_confirmation => 'not-taken'
  end
  
  it "has many sites" do
    @user.should have_many(:sites)
  end  
  
  it "has many memberships" do
    @user.should have_many(:memberships)
  end  
  
  it "has many roles" do
    @user.should have_many(:roles)
  end
    
  
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