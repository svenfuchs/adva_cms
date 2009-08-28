require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class AccountTest < ActiveSupport::TestCase
  def setup
    super
    @user1 = User.find_by_first_name('user1')
    @user2 = User.find_by_first_name('user2')
    @user3 = User.find_by_first_name('user3')
    @user4 = User.find_by_first_name('user4')

    @account = Account.find_by_name('an account')
  end

  test 'creation' do
    @account.name.should == 'an account'
    @account.users.should include(@user1)
    @account.users.should include(@user2)
    @account.users.should include(@user3)
    @account.users.should exclude(@user4)
  end
end
