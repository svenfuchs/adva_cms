require File.dirname(__FILE__) + "/../spec_helper"

describe UserController do
  include Stubby
  include SpecControllerHelper

  before :each do
    scenario :site_with_a_user

    @user_path = '/user'
    @new_user_path = '/user/new'
    @verify_user_path = '/user/verify'

    @params = { :user => { 'first_name' => 'John',
                           'last_name' => 'Doe',
                           'email' => 'email@email.org',
                           'password' => 'password' } }
  end

  describe "GET to :new" do
    act! { request_to :get, @new_user_path }
    it_assigns :user
    it_renders_template :new
  end

  describe "POST to :create" do
    before :each do
      @user.stub!(:state_changes).and_return([:registered])
      @user.stub!(:save).and_return true
      @site.stub!(:save).and_return true
      UserMailer.stub!(:deliver_signup_verification)
    end

    act! { request_to :post, @user_path, @params }
    it_assigns :user

    describe "given valid user params" do
      it_renders_template :verification_sent
      it_triggers_event :user_registered

      it "adds the new user to the site's users collection" do
        @site.users.should_receive(:build).with(@params[:user]).and_return(@user)
        act!
      end
      
      it "sends a validation email to the user" do
        UserMailer.should_receive(:deliver_signup_verification_email)
        act!
      end
    end

    describe "given invalid user params" do
      before :each do
        @site.stub!(:save).and_return false
      end
    
      it_does_not_trigger_any_event
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "GET to :verify" do
    before :each do
      @user = User.new :first_name => 'John', :last_name => 'Doe'
      @user.stub!(:state_changes).and_return([:verified])
      controller.stub!(:current_user).and_return @user
    end
      
    act! { request_to :get, @verify_user_path }
    
    describe "given the user has been logged in from params[:token]" do
      before :each do
        @user.stub!(:verify!).and_return true
      end
      
      it_triggers_event :user_verified
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given the user has not been logged in from params[:token]" do
      before :each do
        @user.stub!(:verify!).and_return false
      end
      
      it_does_not_trigger_any_event
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "DELETE to :destroy" do
    before :each do
      @user = User.new :first_name => 'John', :last_name => 'Doe'
      @user.stub!(:destroy)
      @user.stub!(:state_changes).and_return([:deleted])
      controller.stub!(:current_user).and_return @user
    end
    
    act! { request_to :delete, @user_path }
    it_triggers_event :user_deleted
    it_assigns_flash_cookie :notice => :not_nil
    
    it "deletes the current user" do
      @user.should_receive(:destroy)
      act!
    end
  end
end
