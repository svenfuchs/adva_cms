require File.dirname(__FILE__) + "/../spec_helper"

describe PasswordController do
  include Stubby
  include SpecControllerHelper

  before :each do
    scenario :site_with_a_user

    @password_path = '/password'
    @new_password_path = '/password/new'
    @edit_password_path = '/password/edit'

    @params = { :user => { :email => 'email@email.org',
                           :password => 'password' } }
  end

  describe "GET to :new" do
    act! { request_to :get, @new_password_path }
    it_renders_template :new
  end

  describe "POST to :create" do
    act! { request_to :post, @password_path, @params }
    
    describe "given a valid email address" do
      before :each do
        User.stub!(:find_by_email).with(@params[:user][:email]).and_return @user
      end
      
      it_triggers_event :user_password_reset_requested
      it_assigns_flash_cookie :notice => :not_nil
      it_redirects_to { login_path }
    end
    
    describe "given an invalid email address" do
      before :each do
        User.stub!(:find_by_email).with(@params[:email]).and_return nil
      end
      
      it_does_not_trigger_any_event
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template :new
    end
  end

  describe "GET to :edit" do
    before :each do
      controller.stub!(:current_user).and_return @user
    end
    
    act! { request_to :get, @edit_password_path }
    it_renders_template :edit
  end

  describe "PUT to :update" do
    before :each do
      controller.stub!(:current_user).and_return @user
    end
    
    act! { request_to :put, @password_path, @params }
    
    describe "given valid password parameters" do
      before :each do
        controller.current_user.stub!(:update_attributes).and_return true
      end
      
      it_triggers_event :user_password_updated
      it_assigns_flash_cookie :notice => :not_nil
      it_redirects_to { '/' }
    end
    
    describe "given an invalid email address" do
      before :each do
        controller.current_user.stub!(:update_attributes).and_return false
      end
      
      it_does_not_trigger_any_event
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template :edit
    end
  end
end
