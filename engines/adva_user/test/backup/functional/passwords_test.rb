require File.dirname(__FILE__) + '/../test_helper'
require 'passwords_controller'

# Re-raise errors caught by the controller.
class PasswordsController; def rescue_action(e) raise e end; end

class PasswordsControllerTest < Test::Unit::TestCase
  include Login::UsernameFinder

  fixtures :users

  def setup
    @controller = PasswordsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @deliveries_count = ActionMailer::Base.deliveries.size
  end

  def test_forgot_password_form
    get :new
    assert_response :success
    assert_template 'passwords/new'
  end

  def test_forgot_password
    joe = users(:joe)
    joe.attributes = {:token_key => nil, :token_expiration => nil}
    joe.save!

    put :create, username_field.to_sym => 'joe@example.com'
    assert_message_sent @deliveries_count
    assert_equal 'Notice sent. Please check your email.', flash[:notice]
    assert_redirected_to login_url

    joe.reload
    assert_not_nil joe.token_key
    assert joe.token_expiration > Time.now
    joe.authenticate(joe.token_key)
  end

  def test_forgot_password_invalid_user
    joe = users(:joe)
    joe.attributes = {:token_key => nil, :token_expiration => nil}
    joe.save!

    put :create, username_field.to_sym => 'jack@example.com'
    assert_message_not_sent @deliveries_count
    assert_equal 'User not found.', flash[:warning]
    assert_redirected_to login_url

    joe.reload
    assert_nil joe.token_key
    assert_nil joe.token_expiration
  end

  def test_change_password_form
    @request.session[:uid] = users(:joe).id
    get :edit
    assert_response :success
    assert_template 'passwords/edit'
  end

  def test_change_password
    @request.session[:uid] = users(:joe).id
    post :update, :user => { :password => 'test' }
    assert_equal 'Password successfully updated', flash[:notice]
    assert_message_sent @deliveries_count
    assert_redirected_to home_url
  end

  def test_change_password_not_matched
    @request.session[:uid] = users(:joe).id
    post :update, :user => { :password => 'test' }
    assert_message_not_sent @deliveries_count
    assert_template 'passwords/edit'
  end
end
