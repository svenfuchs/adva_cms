require 'test/unit'
require File.join(File.dirname(__FILE__), 'abstract_unit')

# The goal of this test case is to ensure that the options processing of the
# macro function are being handled properly.
class OptionsTest < Test::Unit::TestCase

  def test_no_args
    auth_mods = UserNoArgs.authentication_modules
    token_mods = UserNoArgs.token_modules

    assert_equal 1, auth_mods.size
    assert_equal 2, token_mods.size

    assert_instance_of Authentication::SaltedHash, auth_mods.first
    assert_instance_of Authentication::RememberMe, token_mods.first
    assert_instance_of Authentication::SingleToken, token_mods.last
  end

  def test_with_auth_mod
    auth_mods = UserWithAuthMod.authentication_modules
    assert_equal 1, auth_mods.size
    assert_instance_of BasicAuthMod, auth_mods.first
  end

  def test_with_token_mod
    token_mods = UserWithTokenMod.token_modules
    assert_equal 1, token_mods.size
    assert_instance_of BasicTokenMod, token_mods.first
  end

  def test_multiple_mods
    auth_mods = UserWithMultipleMods.authentication_modules
    assert_equal 2, auth_mods.size
    assert_instance_of BasicAuthMod, auth_mods.first
    assert_instance_of Authentication::SaltedHash, auth_mods.last
  end

  def test_mods_with_args
    auth_mods = UserWithArgMod.authentication_modules
    assert_equal 1, auth_mods.size
    assert_instance_of ArgAuthMod, auth_mods.first
    assert_equal 1, auth_mods.first.args.size
    assert_equal 'test', auth_mods.first.args.first[:server]
  end

  def test_multiple_mods_with_args
    auth_mods = UserWithMultipleArgs.authentication_modules
    assert_equal 2, auth_mods.size
    assert_instance_of ArgAuthMod, auth_mods.first
    assert_instance_of AnotherArgAuthMod, auth_mods.last
    assert_equal 1, auth_mods.first.args.size
    assert_equal 'test', auth_mods.first.args.first[:server]
    assert_equal 'testing', auth_mods.last.args.first[:server]
  end
end

class UserNoArgs < ActiveRecord::Base
  acts_as_authenticated_user
end

class BasicAuthMod
end

class UserWithAuthMod < ActiveRecord::Base
  acts_as_authenticated_user :authenticate_with => 'BasicAuthMod'
end

class BasicTokenMod
end

class UserWithTokenMod < ActiveRecord::Base
  acts_as_authenticated_user :token_with => 'BasicTokenMod'
end

class UserWithMultipleMods < ActiveRecord::Base
  acts_as_authenticated_user :authenticate_with =>
    ['BasicAuthMod', 'Authentication::SaltedHash']
end

class ArgAuthMod
  def initialize(*args)
    self.args = args
  end
  attr_accessor :args
end
class AnotherArgAuthMod < ArgAuthMod
end

class UserWithArgMod < ActiveRecord::Base
  acts_as_authenticated_user :authenticate_with =>
    {'ArgAuthMod' => {:server => 'test'}}
end

class UserWithMultipleArgs < ActiveRecord::Base
  acts_as_authenticated_user :authenticate_with => [
    {'ArgAuthMod' => {:server => 'test'}},
    {'AnotherArgAuthMod' => {:server => 'testing'}}
  ]
end