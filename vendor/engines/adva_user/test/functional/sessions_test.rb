require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < Test::Unit::TestCase
  include Login::UsernameFinder

  fixtures :users

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    # Assign a password we can auth against
    joe = users(:joe)
    joe.password = 'testing'
    joe.verified_at = Time.now if joe.respond_to? :verified_at
    joe.save!
    joe.reload
  end

  def test_login_form
    get :new
    assert_not_nil assigns['user']
    assert_response :success
    assert_template 'sessions/new'
  end

  def test_login_success_without_remember_me
    put :create, :user => {
      username_field.to_sym => 'joe@example.com',
      :password => 'testing'
    }
    assert_equal users(:joe).id, session[:uid]
    assert_equal 'Login Successful', flash[:notice]
    assert_nil cookies['remember_me']
    assert_redirected_to home_url
  end

  def test_login_success_with_remember_me
    put :create, :user => {
      username_field.to_sym => 'joe@example.com',
      :password => 'testing',
      :remember_me => true
    }
    assert_not_nil cookies['remember_me']
    assert users(:joe).reload.authenticate(cookies['remember_me'].value.first.split(';').last)
  end

  def test_login_failure
    put :create, :user => {
      username_field.to_sym => 'joe@example.com',
      :password => 'fail'
    }
    assert_not_nil assigns['user']
    assert_equal 'Username/Password Incorrect', flash[:warning]
    assert_response :success
    assert_template 'sessions/new'
    assert_select '#username input[value=?]', 'joe@example.com'
  end

  def test_destroy
    @request.session[:uid] = users(:joe).id
    s = session
    delete :destroy
    assert s != session
    assert_redirected_to '/'
  end

  def test_authorization_compatiblity
    assert_generates 'login', DEFAULT_REDIRECTION_HASH
  end
end
