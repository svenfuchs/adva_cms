require 'test/unit'
require 'action_mailer'
require 'action_mailer/ar_sendmail'
require 'rubygems'
require 'test/zentest_assertions'

class ActionMailer::ARSendmail
  attr_accessor :slept
  def sleep(secs)
    @slept ||= []
    @slept << secs
  end
end

class TestARSendmail < Test::Unit::TestCase

  def setup
    ActionMailer::Base.reset
    Email.reset
    Net::SMTP.reset

    @sm = ActionMailer::ARSendmail.new
    @sm.verbose = true

    @include_c_e = ! $".grep(/config\/environment.rb/).empty?
    $" << 'config/environment.rb' unless @include_c_e
  end

  def teardown
    $".delete 'config/environment.rb' unless @include_c_e
  end

  def test_class_create_migration
    out, = util_capture do
      ActionMailer::ARSendmail.create_migration 'Mail'
    end

    expected = <<-EOF
class AddMail < ActiveRecord::Migration
  def self.up
    create_table :mail do |t|
      t.column :from, :string
      t.column :to, :string
      t.column :last_send_attempt, :integer, :default => 0
      t.column :mail, :text
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :mail
  end
end
    EOF

    assert_equal expected, out
  end

  def test_class_create_model
    out, = util_capture do
      ActionMailer::ARSendmail.create_model 'Mail'
    end

    expected = <<-EOF
class Mail < ActiveRecord::Base
end
    EOF

    assert_equal expected, out
  end

  def test_class_mailq
    Email.create :from => nobody, :to => 'recip@h1.example.com',
                 :mail => 'body0'
    Email.create :from => nobody, :to => 'recip@h1.example.com',
                 :mail => 'body1'
    last = Email.create :from => nobody, :to => 'recip@h2.example.com',
                        :mail => 'body2'

    last.last_send_attempt = Time.parse('Thu Aug 10 2006 11:40:05').to_i

    out, err = util_capture do
      ActionMailer::ARSendmail.mailq 'Email'
    end

    expected = <<-EOF
-Queue ID- --Size-- ----Arrival Time---- -Sender/Recipient-------
         1        5 Thu Aug 10 11:19:49  nobody@example.com
                                         recip@h1.example.com

         2        5 Thu Aug 10 11:19:50  nobody@example.com
                                         recip@h1.example.com

         3        5 Thu Aug 10 11:19:51  nobody@example.com
Last send attempt: Thu Aug 10 11:40:05 %s 2006
                                         recip@h2.example.com

-- 0 Kbytes in 3 Requests.
    EOF

    expected = expected % Time.new.strftime('%z')
    assert_equal expected, out
  end

  def test_class_mailq_empty
    out, err = util_capture do
      ActionMailer::ARSendmail.mailq 'Email'
    end

    assert_equal "Mail queue is empty\n", out
  end

  def test_class_new
    @sm = ActionMailer::ARSendmail.new

    assert_equal 60, @sm.delay
    assert_equal Email, @sm.email_class
    assert_equal nil, @sm.once
    assert_equal nil, @sm.verbose
    assert_equal nil, @sm.batch_size

    @sm = ActionMailer::ARSendmail.new :Delay => 75, :Verbose => true,
                                       :TableName => 'Object', :Once => true,
                                       :BatchSize => 1000

    assert_equal 75, @sm.delay
    assert_equal Object, @sm.email_class
    assert_equal true, @sm.once
    assert_equal true, @sm.verbose
    assert_equal 1000, @sm.batch_size
  end

  def test_class_parse_args_batch_size
    options = ActionMailer::ARSendmail.process_args %w[-b 500]

    assert_equal 500, options[:BatchSize]

    options = ActionMailer::ARSendmail.process_args %w[--batch-size 500]

    assert_equal 500, options[:BatchSize]
  end

  def test_class_parse_args_chdir
    argv = %w[-c /tmp]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal '/tmp', options[:Chdir]

    argv = %w[--chdir /tmp]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal '/tmp', options[:Chdir]

    argv = %w[-c /nonexistent]
    
    out, err = util_capture do
      assert_raises SystemExit do
        ActionMailer::ARSendmail.process_args argv
      end
    end
  end

  def test_class_parse_args_daemon
    argv = %w[-d]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal true, options[:Daemon]

    argv = %w[--daemon]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal true, options[:Daemon]
  end
  
  def test_class_parse_args_pidfile
    argv = %w[-p ./log/ar_sendmail.pid]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal './log/ar_sendmail.pid', options[:Pidfile]

    argv = %w[--pidfile ./log/ar_sendmail.pid]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal './log/ar_sendmail.pid', options[:Pidfile]
  end
  
  def test_class_parse_args_delay
    argv = %w[--delay 75]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal 75, options[:Delay]
  end

  def test_class_parse_args_environment
    assert_equal nil, ENV['RAILS_ENV']

    argv = %w[-e production]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal 'production', options[:RailsEnv]

    assert_equal 'production', ENV['RAILS_ENV']

    argv = %w[--environment production]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal 'production', options[:RailsEnv]
  end

  def test_class_parse_args_mailq
    options = ActionMailer::ARSendmail.process_args []
    deny_includes options, :MailQ

    argv = %w[--mailq]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal true, options[:MailQ]
  end

  def test_class_parse_args_max_age
    options = ActionMailer::ARSendmail.process_args []
    assert_equal 86400 * 7, options[:MaxAge]

    argv = %w[--max-age 86400]

    options = ActionMailer::ARSendmail.process_args argv

    assert_equal 86400, options[:MaxAge]
  end

  def test_class_parse_args_migration
    options = ActionMailer::ARSendmail.process_args []
    deny_includes options, :Migration

    argv = %w[--create-migration]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal true, options[:Migrate]
  end

  def test_class_parse_args_model
    options = ActionMailer::ARSendmail.process_args []
    deny_includes options, :Model

    argv = %w[--create-model]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal true, options[:Model]
  end

  def test_class_parse_args_no_config_environment
    $".delete 'config/environment.rb'

    out, err = util_capture do
      assert_raise SystemExit do
        ActionMailer::ARSendmail.process_args []
      end
    end

  ensure
    $" << 'config/environment.rb' if @include_c_e
  end

  def test_class_parse_args_no_config_environment_migrate
    $".delete 'config/environment.rb'

    out, err = util_capture do
      ActionMailer::ARSendmail.process_args %w[--create-migration]
    end

    assert true # count

  ensure
    $" << 'config/environment.rb' if @include_c_e
  end

  def test_class_parse_args_no_config_environment_model
    $".delete 'config/environment.rb'

    out, err = util_capture do
      ActionMailer::ARSendmail.process_args %w[--create-model]
    end

    assert true # count

  rescue SystemExit
    flunk 'Should not exit'

  ensure
    $" << 'config/environment.rb' if @include_c_e
  end

  def test_class_parse_args_once
    argv = %w[-o]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal true, options[:Once]

    argv = %w[--once]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal true, options[:Once]
  end

  def test_class_parse_args_table_name
    argv = %w[-t Email]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal 'Email', options[:TableName]

    argv = %w[--table-name=Email]
    
    options = ActionMailer::ARSendmail.process_args argv

    assert_equal 'Email', options[:TableName]
  end

  def test_class_usage
    out, err = util_capture do
      assert_raises SystemExit do
        ActionMailer::ARSendmail.usage 'opts'
      end
    end

    assert_equal '', out
    assert_equal "opts\n", err

    out, err = util_capture do
      assert_raises SystemExit do
        ActionMailer::ARSendmail.usage 'opts', 'hi'
      end
    end

    assert_equal '', out
    assert_equal "hi\n\nopts\n", err
  end

  def test_cleanup
    e1 = Email.create :mail => 'body', :to => 'to', :from => 'from'
    e1.created_at = Time.now
    e2 = Email.create :mail => 'body', :to => 'to', :from => 'from'
    e3 = Email.create :mail => 'body', :to => 'to', :from => 'from'
    e3.last_send_attempt = Time.now

    out, err = util_capture do
      @sm.cleanup
    end

    assert_equal '', out
    assert_equal "expired 1 emails from the queue\n", err
    assert_equal 2, Email.records.length

    assert_equal [e1, e2], Email.records
  end

  def test_cleanup_disabled
    e1 = Email.create :mail => 'body', :to => 'to', :from => 'from'
    e1.created_at = Time.now
    e2 = Email.create :mail => 'body', :to => 'to', :from => 'from'

    @sm.max_age = 0

    out, err = util_capture do
      @sm.cleanup
    end

    assert_equal '', out
    assert_equal 2, Email.records.length
  end

  def test_deliver
    email = Email.create :mail => 'body', :to => 'to', :from => 'from'

    out, err = util_capture do
      @sm.deliver [email]
    end

    assert_equal 1, Net::SMTP.deliveries.length
    assert_equal ['body', 'from', 'to'], Net::SMTP.deliveries.first
    assert_equal 0, Email.records.length
    assert_equal 0, Net::SMTP.reset_called, 'Reset connection on SyntaxError'

    assert_equal '', out
    assert_equal "sent email 00000000001 from from to to: \"queued\"\n", err
  end

  def test_deliver_auth_error
    Net::SMTP.on_start do
      e = Net::SMTPAuthenticationError.new 'try again'
      e.set_backtrace %w[one two three]
      raise e
    end

    now = Time.now.to_i

    email = Email.create :mail => 'body', :to => 'to', :from => 'from'

    out, err = util_capture do
      @sm.deliver [email]
    end

    assert_equal 0, Net::SMTP.deliveries.length
    assert_equal 1, Email.records.length
    assert_equal 0, Email.records.first.last_send_attempt
    assert_equal 0, Net::SMTP.reset_called
    assert_equal 1, @sm.failed_auth_count
    assert_equal [60], @sm.slept

    assert_equal '', out
    assert_equal "authentication error, retrying: try again\n", err
  end

  def test_deliver_auth_error_recover
    email = Email.create :mail => 'body', :to => 'to', :from => 'from'
    @sm.failed_auth_count = 1

    out, err = util_capture do @sm.deliver [email] end

    assert_equal 0, @sm.failed_auth_count
    assert_equal 1, Net::SMTP.deliveries.length
  end

  def test_deliver_auth_error_twice
    Net::SMTP.on_start do
      e = Net::SMTPAuthenticationError.new 'try again'
      e.set_backtrace %w[one two three]
      raise e
    end

    @sm.failed_auth_count = 1

    out, err = util_capture do
      assert_raise Net::SMTPAuthenticationError do
        @sm.deliver []
      end
    end

    assert_equal 2, @sm.failed_auth_count
    assert_equal "authentication error, giving up: try again\n", err
  end

  def test_deliver_4xx_error
    Net::SMTP.on_send_message do
      e = Net::SMTPSyntaxError.new 'try again'
      e.set_backtrace %w[one two three]
      raise e
    end

    now = Time.now.to_i

    email = Email.create :mail => 'body', :to => 'to', :from => 'from'

    out, err = util_capture do
      @sm.deliver [email]
    end

    assert_equal 0, Net::SMTP.deliveries.length
    assert_equal 1, Email.records.length
    assert_operator now, :<=, Email.records.first.last_send_attempt
    assert_equal 1, Net::SMTP.reset_called, 'Reset connection on SyntaxError'

    assert_equal '', out
    assert_equal "error sending email 1: \"try again\"(Net::SMTPSyntaxError):\n\tone\n\ttwo\n\tthree\n", err
  end

  def test_deliver_5xx_error
    Net::SMTP.on_send_message do
      e = Net::SMTPFatalError.new 'unknown recipient'
      e.set_backtrace %w[one two three]
      raise e
    end

    now = Time.now.to_i

    email = Email.create :mail => 'body', :to => 'to', :from => 'from'

    out, err = util_capture do
      @sm.deliver [email]
    end

    assert_equal 0, Net::SMTP.deliveries.length
    assert_equal 0, Email.records.length
    assert_equal 1, Net::SMTP.reset_called, 'Reset connection on SyntaxError'

    assert_equal '', out
    assert_equal "5xx error sending email 1, removing from queue: \"unknown recipient\"(Net::SMTPFatalError):\n\tone\n\ttwo\n\tthree\n", err
  end

  def test_deliver_errno_epipe
    Net::SMTP.on_send_message do
      raise Errno::EPIPE
    end

    now = Time.now.to_i

    email = Email.create :mail => 'body', :to => 'to', :from => 'from'

    out, err = util_capture do
      @sm.deliver [email]
    end

    assert_equal 0, Net::SMTP.deliveries.length
    assert_equal 1, Email.records.length
    assert_operator now, :>=, Email.records.first.last_send_attempt
    assert_equal 0, Net::SMTP.reset_called, 'Reset connection on SyntaxError'

    assert_equal '', out
    assert_equal '', err
  end

  def test_deliver_server_busy
    Net::SMTP.on_send_message do
      e = Net::SMTPServerBusy.new 'try again'
      e.set_backtrace %w[one two three]
      raise e
    end

    now = Time.now.to_i

    email = Email.create :mail => 'body', :to => 'to', :from => 'from'

    out, err = util_capture do
      @sm.deliver [email]
    end

    assert_equal 0, Net::SMTP.deliveries.length
    assert_equal 1, Email.records.length
    assert_operator now, :>=, Email.records.first.last_send_attempt
    assert_equal 0, Net::SMTP.reset_called, 'Reset connection on SyntaxError'
    assert_equal [60], @sm.slept

    assert_equal '', out
    assert_equal "server too busy, sleeping 60 seconds\n", err
  end

  def test_deliver_syntax_error
    Net::SMTP.on_send_message do
      Net::SMTP.on_send_message # clear
      e = Net::SMTPSyntaxError.new 'blah blah blah'
      e.set_backtrace %w[one two three]
      raise e
    end

    now = Time.now.to_i

    email1 = Email.create :mail => 'body', :to => 'to', :from => 'from'
    email2 = Email.create :mail => 'body', :to => 'to', :from => 'from'

    out, err = util_capture do
      @sm.deliver [email1, email2]
    end

    assert_equal 1, Net::SMTP.deliveries.length, 'delivery count'
    assert_equal 1, Email.records.length
    assert_equal 1, Net::SMTP.reset_called, 'Reset connection on SyntaxError'
    assert_operator now, :<=, Email.records.first.last_send_attempt

    assert_equal '', out
    assert_equal "error sending email 1: \"blah blah blah\"(Net::SMTPSyntaxError):\n\tone\n\ttwo\n\tthree\nsent email 00000000002 from from to to: \"queued\"\n", err
  end

  def test_deliver_timeout
    Net::SMTP.on_send_message do
      e = Timeout::Error.new 'timed out'
      e.set_backtrace %w[one two three]
      raise e
    end

    now = Time.now.to_i

    email = Email.create :mail => 'body', :to => 'to', :from => 'from'

    out, err = util_capture do
      @sm.deliver [email]
    end

    assert_equal 0, Net::SMTP.deliveries.length
    assert_equal 1, Email.records.length
    assert_operator now, :>=, Email.records.first.last_send_attempt
    assert_equal 1, Net::SMTP.reset_called, 'Reset connection on Timeout'

    assert_equal '', out
    assert_equal "error sending email 1: \"timed out\"(Timeout::Error):\n\tone\n\ttwo\n\tthree\n", err
  end

  def test_do_exit
    out, err = util_capture do
      assert_raise SystemExit do
        @sm.do_exit
      end
    end

    assert_equal '', out
    assert_equal "caught signal, shutting down\n", err
  end

  def test_log
    out, err = util_capture do
      @sm.log 'hi'
    end

    assert_equal "hi\n", err
  end

  def test_find_emails
    email_data = [
      { :mail => 'body0', :to => 'recip@h1.example.com', :from => nobody },
      { :mail => 'body1', :to => 'recip@h1.example.com', :from => nobody },
      { :mail => 'body2', :to => 'recip@h2.example.com', :from => nobody },
    ]

    emails = email_data.map do |email_data| Email.create email_data end

    tried = Email.create :mail => 'body3', :to => 'recip@h3.example.com',
                         :from => nobody

    tried.last_send_attempt = Time.now.to_i - 258

    found_emails = []

    out, err = util_capture do
      found_emails = @sm.find_emails
    end

    assert_equal emails, found_emails

    assert_equal '', out
    assert_equal "found 3 emails to send\n", err
  end

  def test_smtp_settings
    ActionMailer::Base.server_settings[:address] = 'localhost'

    assert_equal 'localhost', @sm.smtp_settings[:address]
  end

  def nobody
    'nobody@example.com'
  end

end

