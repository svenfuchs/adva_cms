require File.dirname(__FILE__) + '/../test_helper'
require 'password_notifications'

# This test case will ensure the email configuration is working. The
# password notifications model will be used to perform the test
class MailConfigTest < Test::Unit::TestCase
  fixtures :users

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @reset_link = 'http://example.com/reset_link'
  end

  def test_notifications_from_constant
    Object.const_set('NOTIFICATIONS_FROM', 'administrator@example.org')
    response = PasswordNotifications.create_forgot_password(users(:joe), @reset_link)
    assert_equal Object::NOTIFICATIONS_FROM, response.from[0]
    Object.send :remove_const, 'NOTIFICATIONS_FROM'
  end

  def test_subject_prefix_constant
    Object.const_set('SUBJECT_PREFIX', 'My Organization')
    response = PasswordNotifications.create_forgot_password(users(:joe), @reset_link)
    assert_equal "[#{Object::SUBJECT_PREFIX}] Forgotton Password", response.subject
    Object.send :remove_const, 'SUBJECT_PREFIX'
  end
end