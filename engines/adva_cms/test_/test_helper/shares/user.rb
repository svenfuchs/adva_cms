class Test::Unit::TestCase
  def grant(user, role, context)
    user.roles << Rbac::Role.build(role, :context => context)
  end

  share :is_admin do
    before { grant @controller.current_user, :admin, @site }
  end

  share :is_user do
    before { @controller.current_user.roles.clear }
  end

  share :is_anonymous do
    before { stub(@controller).current_user.returns(nil) }
  end
end