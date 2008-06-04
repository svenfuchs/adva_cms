require File.dirname(__FILE__) + '/../test_helper'
require 'password_notifications'

class PasswordNotificationsTest < Test::Unit::TestCase
  fixtures :users

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @reset_link = 'http://example.com/reset_link'
  end

  def test_forgot_password
    response = PasswordNotifications.create_forgot_password(users(:joe), @reset_link)
    assert_equal 'Forgotton Password', response.subject
    assert_match /Dear #{users(:joe)},/, response.body
    assert_match /#{@reset_link}/, response.body
    assert_equal users(:joe).email, response.to[0]
    assert_equal 'postmaster@example.com', response.from[0]
  end

  def test_update_password
    response = PasswordNotifications.create_updated_password(users(:joe), @reset_link)
    assert_equal 'Password Updated', response.subject
    assert_match /Dear #{users(:joe)},/, response.body
    assert_match /#{@reset_link}/, response.body
    assert_equal users(:joe).email, response.to[0]
    assert_equal 'postmaster@example.com', response.from[0]
  end

end