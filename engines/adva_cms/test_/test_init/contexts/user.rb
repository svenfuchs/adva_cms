class User
  def grant(role, context = nil)
    roles.clear
    roles << Rbac::Role.build(role, :context => context)
  end
end

class Test::Unit::TestCase
  def login(user)
    @user = user
    stub(@controller).current_user.returns(user)
  end

  share :access_granted do
    before do
      stub(@controller).require_authentication
      stub(@controller).guard_permission
    end
  end

  share :no_user do
    before do 
      User.delete_all
    end
  end

  [:superuser, :admin, :moderator, :user, :anonymous].each do |role|
    share :"is_#{role}" do
      before("log in as #{role}") do
        @user = User.find_by_first_name("a #{role}") or raise "could not find user named \"a #{role}\""
        login @user
      end
    end
  end
end