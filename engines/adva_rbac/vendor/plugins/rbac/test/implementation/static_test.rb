require File.dirname(__FILE__) + '/../test_helper'

class RoleTypeStaticTest < Test::Unit::TestCase
  def setup
    Rbac::RoleType.implementation = Rbac::RoleType::Static
  end

  include Rbac::RoleType::Static
  include Tests::ActsAsRoleContext
  include Tests::Context
  include Tests::HasRole
  include Tests::RoleType
  include Tests::Group
end