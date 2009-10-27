require File.dirname(__FILE__) + '/../test_helper'

class RoleTypeActiveRecordTest < Test::Unit::TestCase
  def setup
    Rbac::RoleType.implementation = Rbac::RoleType::ActiveRecord::RoleType
  end

  # include Tests::ActsAsRoleContext
  include Tests::Context
  include Tests::HasRole
  include Tests::RoleType
  include Tests::Group
  
  # def test_foo
  #   p superuser_type.minions
  # end
end