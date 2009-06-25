require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class AccountTest < ActiveSupport::TestCase
  def setup
    super
    @account = Account.find_by_name('Account1')
  end

  test 'creation' do
    with :users do
      @account.name.should == 'Account1'
      @account.users.should include(@user1)
      @account.users.should include(@user2)
      @account.users.should include(@user3)
      @account.users.should exclude(@user4)
    end
  end
end
