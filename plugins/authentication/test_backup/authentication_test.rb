require 'test/unit'
require File.join(File.dirname(__FILE__), 'abstract_unit')

# Will test the various dispatch methods mixed into the user model to enable
# use of the various authentication and token modules. The main goal of this
# test case is not to test the actual authentication but the process of
# dispatching the methods to the various classes that implement the actual
# authentication.
class AuthenticationTest < Test::Unit::TestCase
  fixtures :users

  def teardown
    (RecordedUser.authentication_modules + RecordedUser.token_modules).each do |mod|
      mod.cleanup
    end
  end

  def test_create_user_without_token_or_password
    assert_nothing_raised { User.create! :first_name => 'John', :last_name => 'Doe' }
  end

  def test_authentication_first_success
    first = RecordedUser.authentication_modules.first
    first.send_back :authenticate, true

    jack_with_test_password
    assert @jack.authenticate('test')

    jack_test_auth_message first
  end

  def test_authentication_first_fail_later_success
    first = RecordedUser.authentication_modules.first
    first.send_back :authenticate, false
    last = RecordedUser.authentication_modules.last
    last.send_back :authenticate, true

    jack_with_test_password
    assert @jack.authenticate('test')

    jack_test_auth_message first, last
  end

  def test_authentication_no_success
    first = RecordedUser.authentication_modules.first
    first.send_back :authenticate, false
    last = RecordedUser.authentication_modules.last
    last.send_back :authenticate, false

    jack_with_test_password
    assert !@jack.authenticate('test')

    jack_test_auth_message first, last
  end

  def test_authentication_with_token
    first = RecordedUser.token_modules.first
    first.send_back :authenticate, true

    tok = jack_token
    assert @jack.authenticate(tok)

    jack_test_token_message tok, first
  end

  def test_authentication_with_token_first_fail_later_success
    first = RecordedUser.token_modules.first
    first.send_back :authenticate, false
    last = RecordedUser.token_modules.last
    last.send_back :authenticate, true

    tok = jack_token
    assert @jack.authenticate(tok)

    jack_test_token_message tok, first, last
  end

  def test_authentication_with_token_no_success
    first = RecordedUser.token_modules.first
    first.send_back :authenticate, false
    last = RecordedUser.token_modules.last
    last.send_back :authenticate, false

    tok = jack_token
    assert_nil tok
    assert !@jack.authenticate(tok)

    jack_test_token_message tok, first, last
  end

  def test_assign_token_first_success
    first = RecordedUser.token_modules.first
    first.send_back :assign_token, 'test_token'

    tok = jack_token
    assert_equal 'test_token', tok
    jack_test_assign_tok_message first
  end

  def test_assign_token_first_fail_later_success
    first = RecordedUser.token_modules.first
    first.send_back :assign_token, nil
    last = RecordedUser.token_modules.last
    last.send_back :assign_token, 'last_token'

    tok = jack_token
    assert_equal 'last_token', tok
    jack_test_assign_tok_message first, last
  end

  def test_assign_token_no_success
    first = RecordedUser.token_modules.first
    first.send_back :assign_token, nil
    last = RecordedUser.token_modules.last
    last.send_back :assign_token, nil

    tok = jack_token
    assert_nil tok
    jack_test_assign_tok_message first, last
  end

  def test_assign_password
    first = RecordedUser.authentication_modules.first
    last = RecordedUser.authentication_modules.last

    jane = RecordedUser.new :first_name => 'Jane', :last_name => 'Doe'
    jane.password = 'testing'
    jane.save!
    jane.reload

    [first, last].each do |auth|
      message = auth.last_message

      assert_equal :assign_password, message.first
      assert_equal jane, message[1]
      assert_equal 'testing', message[2]
    end
  end

  def test_blank_password_does_not_overwrite
    jenny = User.new :first_name => 'Jenny'
    jenny.password = 'test'
    jenny.save!
    jenny.reload
    jenny.password = ""
    jenny.save!
    jenny.reload
    assert jenny.authenticate('test')
  end

  private

  def jack_with_test_password
    @jack = RecordedUser.new :first_name => 'Jack'
    @jack.password = 'test'
    @jack.save!
    @jack.reload
  end

  def jack_token
    @jack = RecordedUser.new :first_name => 'Jack'
    tok = @jack.assign_token 'test'
    @jack.save!
    @jack.reload
    tok
  end

  def jack_test_auth_message(*auths)
    auths.each do |auth|
      message = auth.last_message
      assert_equal :authenticate, message.first
      assert_equal @jack, message[1]
      assert_equal 'test', message[2]
    end
  end

  def jack_test_token_message(token, *toks)
    toks.each do |tok|
      message = tok.last_message
      assert_equal :authenticate, message.first
      assert_equal @jack, message[1]
      assert_equal token, message[2]
    end
  end

  def jack_test_assign_tok_message(*toks)
    toks.each do |tok|
      message = tok.last_message
      assert_equal :assign_token, message.first
      assert_equal @jack, message[1]
      assert_equal 3.days.from_now.to_date, message[3].to_date
    end
  end
end

# Utility class that will record everything passed in so we can test the
# receipt of the various messages with the various arguments. This class is
# working both as a cryptor and tokener.
class AuthRecorder
  def initialize(*args)
    @record = []
    @returns = {}
  end
  def method_missing(meth, *args)
    @record << [meth, *args]
    @returns[meth]
  end
  def send_back(meth, ret)
    @returns[meth] = ret
  end
  def last_message
    @record.last
  end
  def cleanup
    @record = []
    @returns = {}
  end
  def assign_token(*args)
    method_missing :assign_token, *args
  end
  def assign_password(*args)
    method_missing :assign_password, *args
  end
end

# Class configured to use a few AuthRecorders
class RecordedUser < User
  acts_as_authenticated_user \
    :authenticate_with => ['AuthRecorder']*2,
    :token_with => ['AuthRecorder']*2
end
