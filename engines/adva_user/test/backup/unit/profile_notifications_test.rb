require File.dirname(__FILE__) + '/../test_helper'
require 'profile_notifications'

class ProfileNotificationsTest < Test::Unit::TestCase
  fixtures :users

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @email_link = 'http://example.com/reset_link'
  end

  def test_forgot_password
    response = ProfileNotifications.create_signup_verification(users(:joe), @email_link)
    assert_equal 'Email Verification', response.subject
    assert_match /Dear #{users(:joe)},/, response.body
    assert_match /#{@email_link}/, response.body
    assert_equal users(:joe).email, response.to[0]
    assert_equal 'postmaster@example.com', response.from[0]
  end

  def test_reactivate_account
    response = ProfileNotifications.create_reactivate_account(users(:joe), @email_link)
    assert_equal 'Account Reactivation', response.subject
    assert_match /Dear #{users(:joe)},/, response.body
    assert_match /#{@email_link}/, response.body
    assert_equal users(:joe).email, response.to[0]
    assert_equal 'postmaster@example.com', response.from[0]
  end

end