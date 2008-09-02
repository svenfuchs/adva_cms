require 'test/unit'
require File.join(File.dirname(__FILE__), 'abstract_unit')

# Tests SingleToken to see if it can allocate tokens and validate
# those tokens correctly
class SingleTokenTest < Test::Unit::TestCase
  include Authentication::HashHelper
  fixtures :users

  def setup
    @tokener = Authentication::SingleToken.new

    @joe = users(:joe)
    @key = @tokener.assign_token @joe, 'standard', 3.days.from_now
    @joe.save!
    @joe.reload
  end

  def test_assign_token
    assert_equal hash_string(@key), @joe.token_key
    assert_equal 3.days.from_now.to_date, @joe.token_expiration.to_date
  end

  def test_authenticate
    assert @tokener.authenticate(@joe, @key)
    assert !@tokener.authenticate(@joe, "invalid key")
  end

  def test_expired_token
    expired_key = @tokener.assign_token @joe, 'past', 1.day.ago
    @joe.save!
    @joe.reload

    assert !@tokener.authenticate(@joe, expired_key)
  end

  def test_token_without_expiration
    no_exp_key = @tokener.assign_token @joe, 'no_exp', nil
    @joe.save!
    @joe.reload

    assert @tokener.authenticate(@joe, no_exp_key)
  end
end