require 'test/unit'
require 'action_mailer'

require 'rubygems'
require 'activesupport'

module Rails; end unless defined?(Rails)
require 'ar_mailer'

##
# Pretend mailer

class Mailer < ActionMailer::Base

  def mail
    @mail = Object.new
    def @mail.encoded() 'email' end
    def @mail.from() ['nobody@example.com'] end
    def @mail.destinations() %w[user1@example.com user2@example.com] end
  end

end

class TestARMailer < Test::Unit::TestCase

  def setup
    ActionMailer::Base.email_class = Email

    Email.records.clear
    Mail.records.clear
  end

  def test_self_email_class_equals
    Mailer.email_class = Mail

    Mailer.deliver_mail

    assert_equal 2, Mail.records.length
  end

  def test_perform_delivery_activerecord
    Mailer.deliver_mail

    assert_equal 2, Email.records.length

    record = Email.records.first
    assert_equal 'email', record.mail
    assert_equal 'user1@example.com', record.to
    assert_equal 'nobody@example.com', record.from

    assert_equal 'user2@example.com', Email.records.last.to
  end

end

