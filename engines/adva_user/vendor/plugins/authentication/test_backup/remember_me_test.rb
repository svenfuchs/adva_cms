require 'test/unit'
require File.join(File.dirname(__FILE__), 'abstract_unit')

# Tests RememberMe to see if it can allocate remember me tokens and
# validate those tokens correctly. This is very similar to single
# token except that it stores in a different field and will not care
# about expiration
class RememberMe < Test::Unit::TestCase
  include Authentication::HashHelper
  fixtures :users

  def setup
    @tokener = Authentication::RememberMe.new

    @joe = users(:joe)
    @key = @tokener.assign_token @joe, 'remember me'
    @joe.save!
    @joe.reload
  end

  def test_assign_remember_me
    assert_equal hash_string(@key), @joe.remember_me
  end

  def test_authenticate
    assert @tokener.authenticate(@joe, @key)
    assert !@tokener.authenticate(@joe, "invalid key")
  end

  def test_expiration_does_not_matter
    expired_key = @tokener.assign_token @joe, 'remember me', 1.day.ago
    @joe.save!
    @joe.reload

    assert @tokener.authenticate(@joe, expired_key)
  end

  def test_non_remember_me
    assert_nil @tokener.assign_token(@joe, 'invalid', 3.days.from_now)
  end
end