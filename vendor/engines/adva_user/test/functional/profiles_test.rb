require File.dirname(__FILE__) + '/../test_helper'
require 'profiles_controller'

# Re-raise errors caught by the controller.
class ProfilesController; def rescue_action(e) raise e end; end

class ProfilesControllerTest < Test::Unit::TestCase
  include Login::UsernameFinder

  fixtures :users

  def setup
    @controller = ProfilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_register_form
    get :new
    assert_not_nil assigns['user']
    assert_response :success
    assert_template 'profiles/new'
  end

  def test_register_success
    jack = 'jack@example.com'
    put :create, :user => {
      username_field.to_sym => jack,
      :password => 'regtest',
      :password_confirmation => 'regtest'
    }
    assert_nil session[:uid]
    assert_nil flash[:notice]
    assert_response :success
    assert_template 'profiles/verification_sent'
  end

  def test_failed_registration
    put :create, :user => {
      username_field.to_sym => 'jane@example.com',
      :password => 'bad',
      :password_confirmation => 'password'
    }
    assert_template 'profiles/new'
  end

  def test_restore_user
    joe = users(:joe)
    joe.deleted_at = Time.now
    joe.verified_at = Time.now
    token = "#{joe.id};#{joe.assign_token('restore')}"
    joe.save!
    put :create, :user => {username_field.to_sym => 'joe@example.com'},
      :token => token
    assert_equal joe.id, session[:uid]
    assert_equal "#{joe} successfully restored", flash[:notice]
    assert_redirected_to home_url
  end

  def test_verification
    @request.session[:uid] = users(:joe).id
    post :update, :verified => true
    assert_not_nil users(:joe).reload.verified_at
    assert_equal "Verified E-mail address for #{users(:joe)}", flash[:notice]
    assert_redirected_to home_url
  end

  def test_destory_user
    @request.session[:uid] = users(:joe).id
    delete :destroy
    assert_not_nil users(:joe).reload.deleted_at
    assert_equal "Successfully deleted user #{users(:joe)}", flash[:notice]
    assert_redirected_to logout_url
  end

end
