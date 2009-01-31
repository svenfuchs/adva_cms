require 'test/unit'
require File.join(File.dirname(__FILE__), 'abstract_unit')

# Tests SaltedHash class to ensure it can authenticate and assign
# passwords correctly
class SaltedHashTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @password = "foobazzle"
    @crypter = Authentication::SaltedHash.new

    @joe = users(:joe)
    @crypter.assign_password @joe, @password
    @joe.save!
    @joe.reload
  end

  # We are basically just going to test that it gets assigned. We can
  # really only test if it was assigned the right value when we test
  # authenticate
  def test_assign_password
    assert_not_nil @joe.password_salt
    assert_not_nil @joe.password_hash
  end

  def test_authenticate
    assert @crypter.authenticate(@joe, @password)
    assert !@crypter.authenticate(@joe, "false password")
  end

  def test_model_validation
    class << User; alias_method :backup_column_names, :column_names end
    def User.column_names; %w(id name password) end
    assert !@crypter.authenticate(@joe, @password)
    class << User; alias_method :column_names, :backup_column_names end
  end
end